<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="utf-8" />
            <meta content="width=device-width, initial-scale=1.0" name="viewport" />
            <title>LBMS - Edit User Account</title>
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
                                "card-light": "#FFFFFF",
                            },
                            fontFamily: { display: ["Inter", "sans-serif"] },
                        }
                    }
                };
            </script>
        </head>

        <body class="bg-background-light font-display text-gray-900 min-h-screen flex items-center justify-center p-4">

            <div
                class="w-full max-w-6xl mx-auto flex overflow-hidden rounded-2xl shadow-xl bg-card-light min-h-[600px]">

                <div class="hidden lg:block lg:w-1/2 relative">
                    <div class="absolute inset-0 bg-primary opacity-90 z-10"></div>
                    <img alt="Library interior"
                        class="absolute inset-0 w-full h-full object-cover grayscale mix-blend-multiply"
                        src="https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&q=80&w=1000" />
                    <div class="relative z-20 h-full flex flex-col justify-between p-12 text-white">
                        <div>
                            <div class="flex items-center space-x-2 mb-2">
                                <span class="material-icons text-3xl">edit_note</span>
                                <h1 class="text-2xl font-bold tracking-tight">LBMS ADMIN</h1>
                            </div>
                            <p class="text-blue-100 text-sm font-medium">Update User Information</p>
                        </div>
                        <div>
                            <h2 class="text-3xl font-bold mb-4 leading-tight">Modifying User Account.</h2>
                            <p class="text-blue-100 leading-relaxed italic">"Updating information ensures the library
                                system remains accurate and secure."</p>
                            <div class="mt-6 p-4 bg-white/10 rounded-lg border border-white/20">
                                <p class="text-xs text-blue-100"> <strong>Note:</strong> Leave the password fields blank
                                    if you do not wish to change the user's current password.</p>
                            </div>
                        </div>
                        <div class="text-xs text-blue-200">© 2026 LBMS Inc. All rights reserved.</div>
                    </div>
                </div>

                <%-- Right Side: Edit Form --%>
                    <div class="w-full lg:w-1/2 p-8 md:p-12 lg:p-16 flex flex-col justify-center">
                        <div class="mb-8 text-center lg:text-left">
                            <h2 class="text-3xl font-bold text-gray-900 mb-2">Edit Account</h2>
                            <p class="text-gray-500 italic">Editing account for: <span
                                    class="text-primary font-semibold">${user.fullName}</span></p>
                        </div>

                        <%-- Validation Errors --%>
                            <c:if test="${not empty errors}">
                                <div id="error-box"
                                    class="mb-6 p-4 bg-red-50 border-l-4 border-red-500 text-red-700 rounded shadow-sm">
                                    <ul class="text-sm">
                                        <c:forEach items="${errors}" var="err">
                                            <li class="flex items-center gap-2"><span
                                                    class="material-icons text-xs">error</span> ${err}</li>
                                        </c:forEach>
                                    </ul>
                                </div>
                            </c:if>

                            <%-- Edit Form --%>
                                <form action="${pageContext.request.contextPath}/admin/users/edit" method="POST"
                                    class="space-y-5">
                                    <input type="hidden" name="id" value="${user.id}">
                                    <input type="hidden" name="page" value="${param.page}">
                                    <input type="hidden" name="keyword" value="${param.keyword}">
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700 mb-1">Full Name</label>
                                        <div class="relative rounded-md shadow-sm">
                                            <div
                                                class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                <span class="material-icons text-gray-400 text-sm">person</span>
                                            </div>
                                            <input type="text" name="name" value="${user.fullName}" required
                                                class="block w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-primary sm:text-sm transition duration-150">
                                        </div>
                                    </div>

                                    <div>
                                        <label class="block text-sm font-medium text-gray-700 mb-1">Email
                                            Address</label>
                                        <div class="relative rounded-md shadow-sm">
                                            <div
                                                class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                <span class="material-icons text-gray-400 text-sm">email</span>
                                            </div>
                                            <input type="email" name="email" value="${user.email}" required
                                                class="block w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-primary sm:text-sm transition duration-150">
                                        </div>
                                    </div>

                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-1">New
                                                Password</label>
                                            <div class="relative rounded-md shadow-sm">
                                                <div
                                                    class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                    <span class="material-icons text-gray-400 text-sm">lock</span>
                                                </div>
                                                <input type="password" name="password" placeholder="Enter password"
                                                    class="block w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-primary sm:text-sm transition duration-150">
                                            </div>
                                        </div>
                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-1">Confirm
                                                Password</label>
                                            <div class="relative rounded-md shadow-sm">
                                                <div
                                                    class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                    <span class="material-icons text-gray-400 text-sm">lock_reset</span>
                                                </div>
                                                <input type="password" name="confirmPassword"
                                                    placeholder="Confirm password"
                                                    class="block w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-primary sm:text-sm transition duration-150">
                                            </div>
                                        </div>
                                    </div>

                                    <div>
                                        <label class="block text-sm font-medium text-gray-700 mb-1">Role</label>
                                        <div class="relative rounded-md shadow-sm">
                                            <div
                                                class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                <span class="material-icons text-gray-400 text-sm">badge</span>
                                            </div>
                                            <select name="roleId"
                                                class="block w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-primary sm:text-sm transition duration-150">
                                                <c:forEach items="${roleList}" var="r">
                                                    <option value="${r.id}" ${user.role.id==r.id ? 'selected' : '' }>
                                                        ${r.name}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="flex flex-col sm:flex-row gap-4 pt-4">
                                        <button type="submit"
                                            class="flex-1 flex justify-center py-3 px-4 border border-transparent rounded-lg shadow-md text-sm font-semibold text-white bg-primary hover:bg-primary-hover focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary transition duration-150 transform hover:-translate-y-0.5">
                                            Update Account
                                        </button>

                                        <a href="${pageContext.request.contextPath}/admin/users?page=${param.page}&keyword=${param.keyword}"
                                            class="flex-1 flex justify-center py-3 px-4 border border-gray-300 rounded-lg shadow-sm text-sm font-semibold text-gray-700 bg-white hover:bg-gray-50 transition duration-150 items-center">
                                            Cancel
                                        </a>
                                    </div>
                                </form>

                                <div class="mt-8 text-center">
                                    <a class="font-medium text-primary hover:underline flex items-center justify-center gap-1"
                                        href="${pageContext.request.contextPath}/admin/users?page=${param.page}&keyword=${param.keyword}">
                                        <span class="material-icons text-sm">arrow_back</span> Back to User List
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
                }, 4000);
            </script>

        </body>

        </html>