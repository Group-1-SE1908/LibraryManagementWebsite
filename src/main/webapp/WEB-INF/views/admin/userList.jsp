<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="utf-8" />
            <meta content="width=device-width, initial-scale=1.0" name="viewport" />
            <title>LBMS - User Management</title>
            <script src="https://cdn.tailwindcss.com?plugins=forms,typography"></script>
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                rel="stylesheet" />
            <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet" />
            <script>
                tailwind.config = {
                    theme: {
                        extend: {
                            colors: {
                                primary: "#1E40AF",
                                "background-light": "#F3F4F6",
                                "card-light": "#FFFFFF",
                            },
                            fontFamily: { display: ["Inter", "sans-serif"] },
                        }
                    }
                };
            </script>
            <style>
                #toast-msg {
                    transition: opacity 0.5s ease-out;
                }
            </style>
        </head>
        <div id="confirmModal" class="fixed inset-0 bg-black/40 hidden items-center justify-center z-50">
            <div class="bg-white rounded-xl shadow-lg w-full max-w-sm p-6">

                <div class="flex items-center gap-3 mb-3">
                    <span class="material-icons text-red-600 text-3xl">warning</span>
                    <h3 class="text-lg font-semibold text-gray-800">
                        Confirm Status Change
                    </h3>
                </div>

                <p class="text-sm text-gray-500 mb-6">
                    Are you sure you want to change this user's status?
                </p>

                <div class="flex justify-end gap-3">
                    <button onclick="closeConfirmModal()"
                        class="px-4 py-2 rounded-lg bg-gray-100 hover:bg-gray-200 text-gray-700">
                        Cancel
                    </button>

                    <button id="confirmSubmitBtn"
                        class="px-4 py-2 rounded-lg bg-red-600 hover:bg-red-700 text-white font-semibold">
                        Confirm
                    </button>
                </div>

            </div>
        </div>

        <script>
            let pendingForm = null;

            function openConfirmModal(form) {
                pendingForm = form;
                const modal = document.getElementById("confirmModal");
                modal.classList.remove("hidden");
                modal.classList.add("flex");
            }

            function closeConfirmModal() {
                document.getElementById("confirmModal").classList.add("hidden");
            }

            document.getElementById("confirmSubmitBtn").addEventListener("click", function () {
                if (pendingForm) pendingForm.submit();
            });
        </script>

        <body class="bg-background-light font-display text-gray-900 min-h-screen p-4 md:p-8">

            <div class="max-w-7xl mx-auto">

                <div class="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
                    <div>
                        <h1 class="text-3xl font-bold text-gray-900 flex items-center gap-2">
                            <span class="material-icons text-primary text-4xl">group</span>
                            User Management
                        </h1>
                        <p class="text-gray-500 mt-1">Manage library members, roles, and account status.</p>
                    </div>

                    <a href="${pageContext.request.contextPath}/admin/users/create"
                        class="inline-flex items-center justify-center px-5 py-2.5 bg-primary text-white font-semibold rounded-lg shadow-sm hover:bg-blue-800 transition-all gap-2">
                        <span class="material-icons text-sm">person_add</span>
                        Add New User
                    </a>
                </div>

                <%-- Notifications --%>
                    <div id="notification-container">
                        <c:if test="${not empty flash}">
                            <c:set var="isErr" value="${flash.contains('Error')}" />
                            <div id="toast-msg"
                                class="mb-4 p-4 ${isErr ? 'bg-red-100 border-red-500 text-red-700' : 'bg-green-100 border-green-500 text-green-700'} border-l-4 rounded shadow-sm flex items-center gap-3">
                                <span class="material-icons">${isErr ? 'report_problem' : 'check_circle'}</span>
                                <span class="font-medium">${flash}</span>
                            </div>
                        </c:if>
                    </div>

                    <%-- Search Bar --%>
                        <div class="bg-card-light rounded-xl shadow-sm p-4 mb-6">

                            <form method="get" action="${pageContext.request.contextPath}/admin/users"
                                class="flex flex-col md:flex-row gap-3">
                                <div class="relative flex-grow">
                                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                        <span class="material-icons text-gray-400 text-sm">search</span>
                                    </div>
                                    <input type="text" name="keyword" value="${keyword}"
                                        class="block w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-primary text-sm"
                                        placeholder="Search by name or email...">
                                </div>
                                <button type="submit"
                                    class="px-6 py-2.5 bg-blue-100 text-blue-700 rounded-lg hover:bg-blue-200 transition-colors text-sm font-medium">
                                    Search
                                </button>

                            </form>
                        </div>

                        <%-- Main Table --%>
                            <div class="bg-card-light rounded-xl shadow-md overflow-hidden">
                                <c:choose>
                                    <c:when test="${not empty userList}">
                                        <div class="overflow-x-auto">
                                            <table class="w-full text-left border-collapse">
                                                <thead>
                                                    <tr
                                                        class="bg-gray-50 border-b border-gray-100 text-gray-600 text-xs uppercase tracking-wider font-semibold">
                                                        <th class="px-6 py-4">ID</th>
                                                        <th class="px-6 py-4">User Details</th>
                                                        <th class="px-6 py-4">Role</th>
                                                        <th class="px-6 py-4 text-center">Status</th>
                                                        <th class="px-6 py-4 text-right">Actions</th>
                                                    </tr>
                                                </thead>
                                                <tbody class="divide-y divide-gray-100">
                                                    <c:forEach var="user" items="${userList}">
                                                        <tr class="hover:bg-blue-50/30 transition-colors">
                                                            <td class="px-6 py-4 text-sm font-medium text-gray-400">
                                                                #${user.id}</td>
                                                            <td class="px-6 py-4">
                                                                <div class="flex items-center gap-3">
                                                                    <div
                                                                        class="h-10 w-10 rounded-full bg-blue-100 flex items-center justify-center text-primary font-bold">
                                                                        <c:out
                                                                            value="${not empty user.fullName ? user.fullName.substring(0,1).toUpperCase() : 'U'}" />
                                                                    </div>
                                                                    <div>
                                                                        <div
                                                                            class="text-sm font-semibold text-gray-900">
                                                                            ${user.fullName}</div>
                                                                        <div class="text-xs text-gray-500">${user.email}
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </td>
                                                            <td class="px-6 py-4">
                                                                <span
                                                                    class="px-3 py-1 bg-gray-100 text-gray-600 rounded-full text-xs font-medium">
                                                                    ${user.role.name}
                                                                </span>
                                                            </td>
                                                            <td class="px-6 py-4 text-center">
                                                                <c:choose>
                                                                    <c:when test="${user.status == 'ACTIVE'}">
                                                                        <span
                                                                            class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                                                                            <span
                                                                                class="w-1.5 h-1.5 rounded-full bg-green-500 mr-1.5"></span>
                                                                            ACTIVE
                                                                        </span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span
                                                                            class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                                                                            <span
                                                                                class="w-1.5 h-1.5 rounded-full bg-red-500 mr-1.5"></span>
                                                                            BLOCKED
                                                                        </span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td class="px-6 py-4 text-right">
                                                                <div class="flex justify-end items-center gap-2">
                                                                    <a href="${pageContext.request.contextPath}/admin/users/view?id=${user.id}&page=${currentPage}&keyword=${keyword}"
                                                                        class="p-2 text-blue-600 hover:bg-blue-100 rounded-lg">
                                                                        <span
                                                                            class="material-icons text-xl">visibility</span>
                                                                    </a>

                                                                    <a href="${pageContext.request.contextPath}/admin/users/edit?id=${user.id}&page=${currentPage}&keyword=${keyword}"
                                                                        class="p-2 text-amber-600 hover:bg-amber-100 rounded-lg">
                                                                        <span class="material-icons text-xl">edit</span>
                                                                    </a>

                                                                    <form
                                                                        action="${pageContext.request.contextPath}/admin/users/status"
                                                                        method="post" class="inline">
                                                                        <input type="hidden" name="id"
                                                                            value="${user.id}">
                                                                        <input type="hidden" name="status"
                                                                            value="${user.status == 'ACTIVE' ? 'BLOCKED' : 'ACTIVE'}">
                                                                        <input type="hidden" name="page"
                                                                            value="${currentPage}">
                                                                        <input type="hidden" name="keyword"
                                                                            value="${keyword}">

                                                                        <button type="button"
                                                                            onclick="openConfirmModal(this.closest('form'))"
                                                                            class="p-2 ${user.status == 'ACTIVE' ? 'text-red-600 hover:bg-red-100' : 'text-green-600 hover:bg-green-100'} rounded-lg">
                                                                            <span
                                                                                class="material-icons text-xl">${user.status
                                                                                == 'ACTIVE' ? 'block' :
                                                                                'lock_open'}</span>
                                                                        </button>

                                                                    </form>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </div>

                                        <%-- Pagination --%>
                                            <div
                                                class="px-6 py-4 bg-gray-50 border-t border-gray-100 flex flex-col md:flex-row items-center justify-between gap-4">
                                                <div class="text-sm text-gray-500">
                                                    Showing <span class="font-semibold text-gray-900">${(currentPage -
                                                        1) * pageSize + 1}</span>
                                                    to <span class="font-semibold text-gray-900">
                                                        <c:set var="endRow" value="${currentPage * pageSize}" />
                                                        ${endRow > totalUsers ? totalUsers : endRow}
                                                    </span>
                                                    of <span class="font-semibold text-gray-900">${totalUsers}</span>
                                                    users
                                                </div>

                                                <nav class="flex items-center gap-1">
                                                    <c:if test="${currentPage > 1}">
                                                        <a href="?page=${currentPage - 1}&keyword=${keyword}"
                                                            class="p-2 text-gray-400 hover:text-primary hover:bg-blue-50 rounded-lg transition-colors">
                                                            <span class="material-icons">chevron_left</span>
                                                        </a>
                                                    </c:if>

                                                    <c:set var="beginPage"
                                                        value="${currentPage - 1 > 0 ? currentPage - 1 : 1}" />
                                                    <c:set var="endPage"
                                                        value="${beginPage + 2 > totalPages ? totalPages : beginPage + 2}" />

                                                    <c:if test="${endPage == totalPages and endPage - 2 > 0}">
                                                        <c:set var="beginPage" value="${endPage - 2}" />
                                                    </c:if>

                                                    <c:forEach begin="${beginPage}" end="${endPage}" var="i">
                                                        <a href="?page=${i}&keyword=${keyword}"
                                                            class="px-3.5 py-1.5 rounded-lg text-sm font-semibold transition-all 
                                       ${i == currentPage ? 'bg-primary text-white shadow-md shadow-blue-200' : 'text-gray-500 hover:bg-gray-100'}">
                                                            ${i}
                                                        </a>
                                                    </c:forEach>

                                                    <c:if test="${currentPage < totalPages}">
                                                        <a href="?page=${currentPage + 1}&keyword=${keyword}"
                                                            class="p-2 text-gray-400 hover:text-primary hover:bg-blue-50 rounded-lg transition-colors">
                                                            <span class="material-icons">chevron_right</span>
                                                        </a>
                                                    </c:if>
                                                </nav>
                                            </div>
                                    </c:when>
                                    <%-- Empty State --%>
                                        <c:otherwise>
                                            <div class="p-12 text-center text-gray-500">
                                                <span
                                                    class="material-icons text-6xl text-gray-200 mb-4">search_off</span>
                                                <p class="text-lg">No users found matching your criteria.</p>
                                                <a href="${pageContext.request.contextPath}/admin/users"
                                                    class="text-primary hover:underline mt-2 inline-block font-medium">Clear
                                                    search and view all</a>
                                            </div>
                                        </c:otherwise>
                                </c:choose>
                            </div>

                            <%-- Footer --%>
                                <div class="mt-4 text-sm text-gray-500 flex justify-between items-center">
                                    <p>© 2026 Library Management System (LBMS)</p>
                                </div>
            </div>

            <script>
                document.addEventListener('DOMContentLoaded', function () {
                    const toast = document.getElementById('toast-msg');
                    if (toast) {
                        setTimeout(function () {
                            toast.style.opacity = '0';
                            setTimeout(function () {
                                toast.style.display = 'none';
                            }, 500);
                        }, 3000);
                    }
                });
            </script>
        </body>

        </html>