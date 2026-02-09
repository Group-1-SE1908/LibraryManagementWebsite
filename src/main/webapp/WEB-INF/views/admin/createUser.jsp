<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="utf-8" />
            <meta content="width=device-width, initial-scale=1.0" name="viewport" />
            <title>LBMS - Admin Create User</title>
            <script src="https://cdn.tailwindcss.com?plugins=forms,typography"></script>
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                rel="stylesheet" />
            <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet" />
            <script>
                tailwind.config = {
                    darkMode: "class",
                    theme: {
                        extend: {
                            colors: {
                                primary: "#1E40AF",
                                "primary-hover": "#1e3a8a",
                                "background-light": "#F3F4F6",
                                "background-dark": "#111827",
                                "card-light": "#FFFFFF",
                                "card-dark": "#1F2937",
                            },
                            fontFamily: {
                                display: ["Inter", "sans-serif"],
                            },
                        },
                    },
                };
            </script>
        </head>

        <body
            class="bg-background-light dark:bg-background-dark font-display text-gray-900 dark:text-gray-100 min-h-screen flex items-center justify-center p-4 transition-colors duration-300">

            <div
                class="w-full max-w-5xl mx-auto flex overflow-hidden rounded-2xl shadow-xl bg-card-light dark:bg-card-dark min-h-[600px]">

                <%-- Left Side Info --%>
                    <div class="hidden lg:block lg:w-5/12 relative">
                        <div class="absolute inset-0 bg-primary opacity-90 z-10"></div>
                        <img alt="Admin Panel" class="absolute inset-0 w-full h-full object-cover"
                            src="https://images.unsplash.com/photo-1507842217343-583bb7270b66?auto=format&fit=crop&q=80&w=1000" />
                        <div class="relative z-20 h-full flex flex-col justify-between p-12 text-white">
                            <div>
                                <div class="flex items-center space-x-2 mb-2">
                                    <span class="material-icons text-3xl">admin_panel_settings</span>
                                    <h1 class="text-2xl font-bold tracking-tight">LBMS ADMIN</h1>
                                </div>
                                <p class="text-blue-100 text-sm font-medium">User Management Module</p>
                            </div>
                            <div>
                                <h2 class="text-3xl font-bold mb-4 leading-tight">Create a new member of the library.
                                </h2>
                                <p class="text-blue-100 leading-relaxed">Ensure all information is accurate. New users
                                    will be set to <span class="font-bold text-green-400">ACTIVE</span> status by
                                    default.</p>
                            </div>
                            <div class="text-xs text-blue-200">© 2026 LBMS Inc. All rights reserved.</div>
                        </div>
                    </div>

                    <%-- Right Side Form --%>
                        <div class="w-full lg:w-7/12 p-8 md:p-12 flex flex-col justify-center">
                            <div class="mb-6">
                                <h2 class="text-3xl font-bold text-gray-900 dark:text-white mb-2">Add New User</h2>
                                <p class="text-gray-500 dark:text-gray-400">Please fill in the details for the new
                                    account.</p>
                            </div>

                            <%-- Display validation errors --%>
                                <c:if test="${not empty errors}">
                                    <div id="error-box"
                                        class="mb-6 p-4 bg-red-50 border-l-4 border-red-500 text-red-700 dark:bg-red-900/20 dark:text-red-400 rounded-r-lg">
                                        <div class="flex items-center mb-1">
                                            <span class="material-icons text-sm mr-2">error</span>
                                            <span class="font-bold">Please correct the following:</span>
                                        </div>
                                        <ul class="list-disc list-inside text-sm">
                                            <c:forEach items="${errors}" var="err">
                                                <li>${err}</li>
                                            </c:forEach>
                                        </ul>
                                    </div>
                                </c:if>

                                <form action="${pageContext.request.contextPath}/admin/users/create" method="POST"
                                    class="space-y-4">

                                    <div>
                                        <label
                                            class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Full
                                            Name</label>
                                        <div class="relative">
                                            <div
                                                class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                <span class="material-icons text-gray-400 text-sm">person</span>
                                            </div>
                                            <%-- Dùng value="${param.name}" để giữ lại giá trị nếu có lỗi --%>
                                                <input type="text" name="name" value="${param.name}" required
                                                    class="block w-full pl-10 pr-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary focus:border-primary sm:text-sm"
                                                    placeholder="Enter user's full name" />
                                        </div>
                                    </div>

                                    <div>
                                        <label
                                            class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Email
                                            Address</label>
                                        <div class="relative">
                                            <div
                                                class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                <span class="material-icons text-gray-400 text-sm">email</span>
                                            </div>
                                            <input type="email" name="email" value="${param.email}" required
                                                class="block w-full pl-10 pr-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary focus:border-primary sm:text-sm"
                                                placeholder="email@example.com" />
                                        </div>
                                    </div>

                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                        <div>
                                            <label
                                                class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Password</label>
                                            <div class="relative">
                                                <div
                                                    class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                    <span class="material-icons text-gray-400 text-sm">lock</span>
                                                </div>
                                                <input type="password" name="password" required
                                                    class="block w-full pl-10 pr-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary focus:border-primary sm:text-sm"
                                                    placeholder="Enter password" />
                                            </div>
                                        </div>

                                        <div>
                                            <label
                                                class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Confirm
                                                Password</label>
                                            <div class="relative">
                                                <div
                                                    class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                    <span class="material-icons text-gray-400 text-sm">lock_reset</span>
                                                </div>
                                                <input type="password" name="confirmPassword" required
                                                    class="block w-full pl-10 pr-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary focus:border-primary sm:text-sm"
                                                    placeholder="Confirm password" />
                                            </div>
                                        </div>
                                    </div>

                                    <div>
                                        <label
                                            class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Assign
                                            Role</label>
                                        <div class="relative">
                                            <div
                                                class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                <span class="material-icons text-gray-400 text-sm">badge</span>
                                            </div>
                                            <select name="roleId" required
                                                class="block w-full pl-10 pr-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary focus:border-primary sm:text-sm">
                                                <c:forEach items="${roleList}" var="r">
                                                    <option value="${r.id}" ${param.id==r.id ? 'selected' : '' }>
                                                        ${r.name}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="flex flex-col sm:flex-row gap-3 pt-4">
                                        <button type="submit"
                                            class="flex-1 flex justify-center py-2.5 px-4 border border-transparent rounded-lg shadow-sm text-sm font-semibold text-white bg-primary hover:bg-primary-hover focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary transition duration-150">
                                            Save User
                                        </button>
                                        <a href="${pageContext.request.contextPath}/admin/users"
                                            class="flex-1 flex justify-center py-2.5 px-4 border border-gray-300 dark:border-gray-600 rounded-lg shadow-sm text-sm font-semibold text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 transition duration-150 items-center">
                                            Cancel
                                        </a>
                                    </div>
                                </form>

                                <div class="mt-6 text-center lg:text-left">
                                    <a href="${pageContext.request.contextPath}/admin/users"
                                        class="text-sm font-medium text-primary hover:underline flex items-center justify-center lg:justify-start gap-1">
                                        <span class="material-icons text-sm">arrow_back</span> Return to User List
                                    </a>
                                </div>
                        </div>
            </div>

            <script>
                setTimeout(() => {
                    const errorBox = document.getElementById('error-box');
                    if (errorBox) {
                        errorBox.style.transition = 'opacity 0.5s ease';
                        errorBox.style.opacity = '0';
                        setTimeout(() => errorBox.remove(), 500);
                    }
                }, 5000);
            </script>

        </body>

        </html>