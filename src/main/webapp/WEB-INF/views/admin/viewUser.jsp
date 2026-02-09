<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="utf-8" />
            <meta content="width=device-width, initial-scale=1.0" name="viewport" />
            <title>LBMS - User Account</title>
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
                                "background-light": "#F3F4F6"
                            },
                            fontFamily: { display: ["Inter", "sans-serif"] }
                        }
                    }
                };
            </script>
        </head>

        <body class="bg-background-light font-display text-gray-900 min-h-screen flex items-center justify-center p-4">

            <div class="w-full max-w-2xl bg-white rounded-2xl shadow-xl overflow-hidden">
                <div class="h-32 bg-primary relative">
                    <div class="absolute -bottom-12 left-8">
                        <div
                            class="h-24 w-24 rounded-2xl bg-white shadow-lg flex items-center justify-center border-4 border-white">
                            <span class="material-icons text-primary text-5xl">account_circle</span>
                        </div>
                    </div>
                </div>
                <%-- Content Section --%>
                    <div class="pt-16 pb-8 px-8">
                        <div class="flex justify-between items-start mb-6">
                            <div>
                                <h2 class="text-2xl font-bold text-gray-900">${user.fullName}</h2>
                                <p class="text-sm text-gray-500 font-medium">User ID: #${user.id}</p>
                            </div>
                            <c:choose>
                                <c:when test="${user.status == 'ACTIVE'}">
                                    <span
                                        class="px-3 py-1 bg-green-100 text-green-700 rounded-full text-xs font-bold flex items-center gap-1">
                                        <span class="w-2 h-2 rounded-full bg-green-500"></span> ACTIVE
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span
                                        class="px-3 py-1 bg-red-100 text-red-700 rounded-full text-xs font-bold flex items-center gap-1">
                                        <span class="w-2 h-2 rounded-full bg-red-500"></span> BLOCKED
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <hr class="border-gray-100 mb-6">

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div class="flex items-start gap-3">
                                <div class="p-2 bg-blue-50 rounded-lg">
                                    <span class="material-icons text-primary">person</span>
                                </div>
                                <div>
                                    <p class="text-xs text-gray-400 uppercase font-bold tracking-wider">Full Name</p>
                                    <p class="text-gray-700 font-medium">${user.fullName}</p>
                                </div>
                            </div>

                            <div class="flex items-start gap-3">
                                <div class="p-2 bg-blue-50 rounded-lg">
                                    <span class="material-icons text-primary">email</span>
                                </div>
                                <div>
                                    <p class="text-xs text-gray-400 uppercase font-bold tracking-wider">Email Address
                                    </p>
                                    <p class="text-gray-700 font-medium">${user.email}</p>
                                </div>
                            </div>

                            <div class="flex items-start gap-3">
                                <div class="p-2 bg-blue-50 rounded-lg">
                                    <span class="material-icons text-primary">badge</span>
                                </div>
                                <div>
                                    <p class="text-xs text-gray-400 uppercase font-bold tracking-wider">Role</p>
                                    <p class="text-gray-700 font-medium">${user.role.name}</p>
                                </div>
                            </div>
                        </div>
                        <div class="mt-10 flex flex-col sm:flex-row gap-3">

                            <a href="${pageContext.request.contextPath}/admin/users/edit?id=${user.id}&page=${param.page}&keyword=${param.keyword}"
                                class="flex-1 flex justify-center items-center gap-2 py-3 px-4 bg-amber-500 hover:bg-amber-600 text-white font-semibold rounded-xl shadow-sm transition-all">
                                <span class="material-icons text-sm">edit</span>
                                Edit Account
                            </a>


                            <a href="${pageContext.request.contextPath}/admin/users?page=${not empty param.page ? param.page : 1}&keyword=${param.keyword}"
                                class="flex-1 flex justify-center items-center gap-2 py-3 px-4 bg-gray-100 hover:bg-gray-200 text-gray-700 font-semibold rounded-xl shadow-sm transition-all">
                                <span class="material-icons text-sm">arrow_back</span>
                                Back to List
                            </a>
                        </div>
                    </div>

        </body>

        </html>