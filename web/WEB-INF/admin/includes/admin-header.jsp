<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="path" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hệ Thống Quản Trị - FurniShop</title>

    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: { sans: ['"Plus Jakarta Sans"', 'sans-serif'] },
                    colors: {
                        brand: { 500: '#6366f1', 600: '#4f46e5' } /* Indigo */
                    }
                }
            }
        }
    </script>
    <style>
        body { background-color: #f8fafc; color: #1e293b; overflow: hidden; } /* Ngăn cuộn body */
        
        /* Glassmorphism Classes */
        .glass {
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.5);
        }
        
        /* Animations */
        .hover-lift { transition: transform 0.2s cubic-bezier(0.4, 0, 0.2, 1); }
        .hover-lift:hover { transform: translateY(-2px); }
        
        /* Custom Scrollbar */
        .custom-scroll::-webkit-scrollbar { width: 5px; height: 5px; }
        .custom-scroll::-webkit-scrollbar-track { background: transparent; }
        .custom-scroll::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }
        .custom-scroll::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
        
        /* Table Styles */
        .table-row-hover:hover { background-color: rgba(99, 102, 241, 0.04); }
    </style>
</head>
<body class="antialiased">

<div id="app-wrapper" class="flex h-screen w-full bg-slate-50 relative">

    <jsp:include page="admin-sidebar.jsp"/>

    <div class="flex-1 flex flex-col min-w-0 h-full relative overflow-hidden">
        
        <header class="h-20 glass flex items-center justify-between px-6 z-30 flex-shrink-0 sticky top-0 border-b border-slate-200/60">
            <div class="flex items-center gap-4">
                <button onclick="toggleSidebar()" class="lg:hidden p-2 text-slate-500 hover:bg-slate-100 rounded-lg transition-colors">
                    <i class="fa-solid fa-bars text-xl"></i>
                </button>
                <div class="hidden md:block">
                    <h2 class="text-lg font-bold text-slate-800 tracking-tight">Dashboard Quản Trị</h2>
                    <p class="text-xs text-slate-500 font-medium">Phiên làm việc: ${pageContext.session.creationTime}</p>
                </div>
            </div>

            <div class="flex items-center gap-5">
                <div class="hidden md:flex items-center bg-white border border-slate-200 rounded-full px-4 py-2 shadow-sm focus-within:ring-2 focus-within:ring-brand-500 transition-all w-64">
                    <i class="fa-solid fa-magnifying-glass text-slate-400 text-sm"></i>
                    <input type="text" placeholder="Tìm kiếm nhanh..." class="bg-transparent border-none outline-none text-sm ml-3 w-full text-slate-600 placeholder-slate-400">
                </div>

                <button class="relative w-10 h-10 bg-white border border-slate-200 rounded-full flex items-center justify-center text-slate-500 hover:text-brand-600 hover:shadow-md transition-all hover-lift">
                    <i class="fa-regular fa-bell"></i>
                    <span class="absolute top-2 right-2 w-2.5 h-2.5 bg-red-500 rounded-full border-2 border-white animate-pulse"></span>
                </button>

                <div class="flex items-center gap-3 pl-5 border-l border-slate-200">
                    <div class="text-right hidden md:block">
                        <p class="text-sm font-bold text-slate-800">
                            <c:out value="${sessionScope.account.fullName}" default="Administrator"/>
                        </p>
                        <p class="text-[10px] font-bold text-brand-600 uppercase tracking-wider">Super Admin</p>
                    </div>
                    <div class="w-10 h-10 rounded-full p-0.5 bg-gradient-to-tr from-brand-500 to-purple-500 shadow-md cursor-pointer hover-lift">
                        <img src="https://ui-avatars.com/api/?name=${sessionScope.account.fullName}&background=fff&color=4f46e5" 
                             class="w-full h-full rounded-full border-2 border-white object-cover">
                    </div>
                </div>
            </div>
        </header>

        <main class="flex-1 overflow-y-auto p-4 md:p-8 custom-scroll relative bg-slate-50/50">