# Library Management System - Reservation Feature Complete Summary

## 📋 Quick Reference Guide

---

## 1️⃣ DATABASE SCHEMA

### Table: `reservations`

```sql
CREATE TABLE reservations (
    id             BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id        INT           NOT NULL,
    book_id        INT           NOT NULL,
    status         VARCHAR(20)   NOT NULL DEFAULT 'WAITING',
    queue_position INT           NULL,
    note           NVARCHAR(255) NULL,
    notified_at    DATETIME      NULL,
    expired_at     DATETIME      NULL,
    created_at     DATETIME      NOT NULL DEFAULT GETDATE(),
    updated_at     DATETIME      NULL,
    CONSTRAINT FK_Res_User FOREIGN KEY (user_id) REFERENCES [User](user_id),
    CONSTRAINT FK_Res_Book FOREIGN KEY (book_id) REFERENCES Book(book_id)
);

-- Indexes
CREATE INDEX IX_Res_UserId ON reservations (user_id);
CREATE INDEX IX_Res_BookId ON reservations (book_id);
CREATE INDEX IX_Res_Status ON reservations (status);
```

**Status Values:** `WAITING` | `AVAILABLE` | `BORROWED` | `CANCELLED` | `EXPIRED`

---

## 2️⃣ API ENDPOINTS

### Member-Side: ReservationServlet

```
GET    /reservation
       → Displays member's reservations
       → Response: reservation_list.jsp

POST   /reservation?action=add
       → Create new reservation
       → Input: bookId
       → Validation: book.quantity=0, no duplicates, max 3, max 5 total

POST   /reservation?action=cancel
       → Cancel active reservation
       → Input: resId
       → Effect: Status=CANCELLED, re-order queue, notify

POST   /reservation?action=markAllRead
       → Mark all notifications read
```

### Librarian-Side: LibrarianReservationController

```
GET    /staff/reservation
       → View all reservations
       → Response: admin/library/reservation_list.jsp

GET    /staff/reservation?action=queue&bookId=X
       → View queue for specific book
       → Response: admin/library/reservation_queue.jsp

POST   /staff/reservation?action=approve
       → Confirm user picked up book
       → Input: reservationId
       → Effect: Create BorrowRecord, Status=BORROWED, Notify
       → Response: JSON {success/error}

POST   /staff/reservation?action=reject
       → Reject/cancel reservation
       → Input: reservationId, reason (optional)
       → Effect: Status=CANCELLED, Move queue, Notify with reason

POST   /staff/reservation?action=scan
       → Verify barcode matches
       → Input: reservationId, barcode
       → Effect: If match → confirmReservationPickup()
```

---

## 3️⃣ BUSINESS RULES & CONSTRAINTS

### Creation Rules

```java
// From ReservationService.createReservation()

✓ PASS: Book exists AND quantity = 0
✗ FAIL: Book has quantity > 0 → "Sách hiện còn sẵn"
✗ FAIL: Already has active reservation → "Bạn đã đặt trước cuốn sách này rồi"
✗ FAIL: >= 3 active reservations → "Bạn đã đạt giới hạn 3 đặt trước"
✗ FAIL: (activeBorrows + activeReservations) >= 5 → "Tổng bạn có X mượn + Y đặt trước = Z/5"

On Success:
- Find old CANCELLED/EXPIRED record → reactivate with new queue_position
- Or create new record
- Status = WAITING, queue_position = next available
```

### Availability Window Rules

```
When Book Returned → onBookReturned(bookId):
  1. Get first WAITING person
  2. Set Status = AVAILABLE
  3. Set notified_at = NOW()
  4. Set expired_at = NOW() + 3 DAYS
  5. Set queue_position = 1
  6. Re-order all WAITING: queue_position > 1 → -1
  7. Send notification: "Your book is ready!"

Scheduler: processExpiredReservations()
  1. Find all AVAILABLE where expired_at < NOW()
  2. Set Status = EXPIRED
  3. Send notification: "Reservation expired"
  4. Call onBookReturned() for next person → cascade

Reminder: processExpiringReminders()
  1. Find AVAILABLE where expired_at BETWEEN NOW and NOW+24h
  2. Exclude: note contains '[REMINDED]'
  3. Send: "Your reservation expires in X hours"
  4. Mark: note += '[REMINDED]'
```

### Cancellation Rules

```
Member Can Cancel:
  ✓ Status = WAITING
  ✓ Status = AVAILABLE (but risky, has deadline)
  ✗ Status = CANCELLED, BORROWED, EXPIRED

Cancellation Effect:
  1. Set Status = CANCELLED
  2. Set queue_position = NULL
  3. Re-order: All queue_position > removed_pos → -1
  4. Notify user
  5. Call onBookReturned() for next if book available

Librarian Can:
  ✓ Reject any reservation with reason
  ✓ Mark no-show (AVAILABLE → CANCELLED)
  ✓ Cancel for policy reasons
```

---

## 4️⃣ KEY CODE SNIPPETS

### Creating Reservation

```java
// File: ReservationService.java
public long createReservation(long userId, long bookId) throws SQLException {
    // Validation checks
    Book book = bookDAO.findById(bookId);
    if (book == null) throw new IllegalArgumentException("Sách không tồn tại");
    if (book.getQuantity() > 0) throw new IllegalArgumentException("Sách còn sẵn");
    if (reservationDAO.existsActive(userId, bookId)) throw new IllegalArgumentException("Đã đặt rồi");

    int activeRes = reservationDAO.countActive(userId);
    if (activeRes >= MAX_RESERVATIONS) throw new IllegalArgumentException("Đạt giới hạn 3");

    // Get queue position and create
    int queuePos = reservationDAO.getNextQueuePosition(bookId);
    Reservation old = reservationDAO.findCancelledOrExpired(userId, bookId);

    long resId;
    if (old != null) {
        reservationDAO.reactivate(old.getId(), queuePos);
        resId = old.getId();
    } else {
        resId = reservationDAO.create(userId, bookId, queuePos);
    }
    return resId;
}
```

### When Book Returned

```java
// File: ReservationService.java
public void onBookReturned(long bookId) throws SQLException {
    Reservation first = reservationDAO.getFirstWaiting(bookId);
    if (first == null) return;

    // Mark first in queue as AVAILABLE with 3-day deadline
    reservationDAO.markAvailable(first.getId());

    // Notify the member
    notifService.notifyBookAvailable(first.getUserId(), first.getBookTitle());
}
```

### Auto-Expiring Reservations

```java
// File: ReservationService.java
public void processExpiredReservations() throws SQLException {
    List<Reservation> expired = reservationDAO.findExpiredAvailable();
    for (Reservation res : expired) {
        reservationDAO.updateStatus(res.getId(), "EXPIRED");
        notifService.notifyReservationExpired(res.getUserId(), res.getBookTitle());

        // Move next person up
        Book book = bookDAO.findById(res.getBookId());
        if (book != null && book.getQuantity() > 0) {
            onBookReturned(res.getBookId());
        }
    }
}
```

### Getting Queue for Book

```java
// File: ReservationDAO.java
public List<Reservation> listWaitingQueue(long bookId) throws SQLException {
    String sql = "SELECT r.*, b.*, u.* " +
        "ROW_NUMBER() OVER (ORDER BY " +
        "  CASE WHEN r.status='AVAILABLE' THEN 0 ELSE 1 END, r.created_at ASC) AS queue_position " +
        "FROM reservations r " +
        "INNER JOIN Book b ON r.book_id = b.book_id " +
        "INNER JOIN [User] u ON r.user_id = u.user_id " +
        "WHERE book_id = ? AND status IN ('WAITING', 'AVAILABLE') " +
        "ORDER BY queue_position";
    // Returns list with computed queue_position (AVAILABLE first, then WAITING by date)
}
```

### Queue Re-ordering

```sql
-- When person cancels (reorderQueueAfterRemoval)
UPDATE reservations
SET queue_position = queue_position - 1, updated_at = GETDATE()
WHERE book_id = ?
  AND status IN ('WAITING', 'AVAILABLE')
  AND queue_position > [removedPosition];

-- When marking person as AVAILABLE (markAvailable)
UPDATE reservations
SET queue_position = queue_position - 1, updated_at = GETDATE()
WHERE book_id = ?
  AND status = 'WAITING'
  AND queue_position > 1;
```

---

## 5️⃣ STATE TRANSITIONS

```
Creation:
  None → WAITING (queue_position = X)

Progression:
  WAITING → AVAILABLE (when book returned, gets 3-day deadline)
  AVAILABLE → BORROWED (member picks up, converted to borrow)
  AVAILABLE → EXPIRED (after 3 days, scheduler marks)

Cancellation:
  WAITING → CANCELLED (member/staff cancels)
  AVAILABLE → CANCELLED (staff marks no-show)
  CANCELLED → WAITING (if member reserves same book again)

Terminal States:
  BORROWED (completed successfully)
  EXPIRED (deadline missed)
  CANCELLED (user/staff cancelled)
```

---

## 6️⃣ NOTIFICATIONS

Events that trigger notifications:

| Event                 | Method                     | Recipient | Message                                          |
| --------------------- | -------------------------- | --------- | ------------------------------------------------ |
| Book Available        | notifyBookAvailable        | User      | "Your book is ready! Pick up by [date]"          |
| Reservation Cancelled | notifyReservationCancelled | User      | "Your reservation for [book] has been cancelled" |
| Reservation Expired   | notifyReservationExpired   | User      | "Your reservation for [book] has expired"        |
| Expiring Soon (24h)   | notifyBookExpiringSoon     | User      | "Your reservation expires in [X] hours"          |
| Borrowed              | notifyReservationBorrowed  | User      | "Your reservation has been converted to borrow"  |

---

## 7️⃣ UI PAGES

### Member Page: `reservation_list.jsp`

- Location: `/WEB-INF/views/reservation_list.jsp`
- Shows: All member's reservations
- Status display:
  - 🟡 WAITING (queue position shown)
  - 🟠 AVAILABLE (with deadline countdown)
  - ✅ BORROWED
  - ❌ CANCELLED
  - ⏰ EXPIRED
- Actions: Cancel button for WAITING/AVAILABLE

### Admin Page: `admin/library/reservation_list.jsp`

- Location: `/WEB-INF/views/admin/library/reservation_list.jsp`
- Shows: All system reservations grouped by book
- Filter: By status
- User info: Name, email
- Actions:
  - ✅ Xác nhận lấy sách (Confirm pickup)
  - ❌ Từ chối (Reject)
  - ⏱️ User không tới (Mark no-show)
  - 📋 Xem Queue (View queue)

### Queue Page: `admin/library/reservation_queue.jsp`

- Location: `/WEB-INF/views/admin/library/reservation_queue.jsp`
- Shows: Queue for 1 specific book
- Table: Position | Status | User | Email | Phone | Created | Deadline
- Summary: Total queue size, who's ready to pickup

---

## 8️⃣ FILE STRUCTURE

```
src/main/java/com/lbms/
├── model/
│   └── Reservation.java              ← Entity model
├── service/
│   ├── ReservationService.java       ← Business logic
│   └── NotificationService.java      ← Notification handling
├── dao/
│   └── ReservationDAO.java           ← Data access
└── controller/
    ├── ReservationServlet.java       ← Member endpoints
    └── LibrarianReservationController.java ← Staff endpoints

src/main/webapp/WEB-INF/views/
├── reservation_list.jsp              ← Member page
└── admin/library/
    ├── reservation_list.jsp          ← Admin all-reservations
    └── reservation_queue.jsp         ← Admin queue page

src/main/resources/
├── schema.sql                        ← Reservations table definition
└── seed_account.sql                  ← Sample data
```

---

## 9️⃣ CONFIGURATION

### ReservationService Constants

```java
private static final int MAX_RESERVATIONS = 3;    // Max concurrent per member
private static final int MAX_TOTAL = 5;           // Max combined (borrows + res)
```

### Time Windows

```
AVAILABLE duration: 3 days (72 hours)
Reminder window: 24 hours before expiry
Scheduler frequency: Daily for expiry, Hourly for reminders
```

### Scheduler Tasks (if available)

```java
@Scheduled(cron = "0 0 * * * *")  // Every hour
processExpiringReminders()

@Scheduled(cron = "0 0 0 * * *")  // Every day 00:00
processExpiredReservations()
```

---

## 🔟 EXCEPTION HANDLING

### Business Rule Violations (User Errors)

```java
throw new IllegalArgumentException("Message")
// Caught in servlet → Flash error → Redirect with error message
```

### Database Errors (System Errors)

```java
throw new SQLException("Message")
// Caught in servlet → ServletException → Error page
```

### Validation Errors

```java
NumberFormatException → Invalid ID format
→ Flash error → Reload page
```

---

## 📊 DATA FLOW DIAGRAM

```
Member Request → ReservationServlet (GET/POST)
    ↓
    ├→ GET /reservation
    │   └→ ReservationService.listByUser()
    │       └→ ReservationDAO.listByUser()
    │           └→ DB query with joins
    │               └→ JSP render
    │
    ├→ POST /reservation?action=add
    │   └→ ReservationService.createReservation()
    │       ├→ Validations (book, active, limit, combined)
    │       ├→ ReservationDAO.getNextQueuePosition()
    │       ├→ ReservationDAO.create() or .reactivate()
    │       └→ NotificationService.log event (optional)
    │           └→ Flash success → Redirect
    │
    └→ POST /reservation?action=cancel
        └→ ReservationService.cancelReservation()
            ├→ ReservationDAO.cancel()
            │   └→ reorderQueueAfterRemoval()
            └→ NotificationService.notify()
                └→ Flash success → Redirect
```

---

## 🔐 ACCESS CONTROL

| Endpoint                            | Member | Librarian | Admin | Public |
| ----------------------------------- | ------ | --------- | ----- | ------ |
| GET /reservation                    | ✓      | ✓         | ✓     | ✗      |
| POST /reservation (add)             | ✓      | ✗         | ✗     | ✗      |
| POST /reservation (cancel)          | ✓      | ✗         | ✗     | ✗      |
| GET /staff/reservation              | ✗      | ✓         | ✓     | ✗      |
| GET /staff/reservation?action=queue | ✗      | ✓         | ✓     | ✗      |
| POST /staff/reservation (approve)   | ✗      | ✓         | ✓     | ✗      |
| POST /staff/reservation (reject)    | ✗      | ✓         | ✓     | ✗      |
| POST /staff/reservation (scan)      | ✗      | ✓         | ✓     | ✗      |

---

## ✅ COMPLETE WORKFLOW CHECKLIST

### Member Workflow

- [ ] Browse book (see "Đặt trước" if out of stock)
- [ ] Click reserve button
- [ ] System validates and creates reservation
- [ ] Member sees status: WAITING + queue position
- [ ] Wait for book return…
- [ ] Receive notification: "Book ready!"
- [ ] Status changes to: AVAILABLE + deadline
- [ ] Come to library within 3 days
- [ ] Librarian confirms pickup
- [ ] Reservation converted to BorrowRecord
- [ ] Book added to member's active borrows
- [ ] Return book on or before due date

### Librarian Workflow

- [ ] View `/staff/reservation` for all pending reservations
- [ ] See: User, book, status, queue info
- [ ] When book returned:
  - [ ] System auto-marks first in queue as AVAILABLE
  - [ ] Notification sent to member
- [ ] When member comes to pickup:
  - [ ] Click "Confirm pickup" OR
  - [ ] Scan barcode to verify
- [ ] System creates BorrowRecord automatically
- [ ] Member now has book borrowed for 7 days

### Auto-Processing

- [ ] Scheduler daily: Find expired AVAILABLE → mark EXPIRED
- [ ] Scheduler hourly: Find expiring within 24h → send reminder
- [ ] Auto-cascade: onBookReturned() called for next in queue
- [ ] Queue positions automatically maintained

---

## 🐛 TROUBLESHOOTING

| Issue                            | Cause                      | Solution                                  |
| -------------------------------- | -------------------------- | ----------------------------------------- |
| Can't reserve book in stock      | Book quantity > 0          | Only out-of-stock books can be reserved   |
| "Max reservations reached" error | User has 3+ active         | Cancel some reservations first            |
| Queue position stuck             | Queue not reordered        | Check if re-order SQL ran properly        |
| Notification not received        | Task scheduler not running | Check scheduler configuration             |
| Person ahead didn't pick up      | Expired deadline           | Run processExpiredReservations() manually |

---

**Last Updated:** 2026-03-26  
**Status:** Production Ready  
**Test Coverage:** Basic flows + edge cases
