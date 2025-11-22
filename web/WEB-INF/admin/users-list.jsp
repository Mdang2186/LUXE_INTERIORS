<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="path" value="${pageContext.request.contextPath}" />

<jsp:include page="/WEB-INF/admin/includes/admin-header.jsp"/>
<jsp:include page="includes/admin-sidebar.jsp"/>

<main class="admin-content-main">

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h1 class="luxe-title m-0">Quản lý Người dùng</h1>
        <form class="d-flex gap-2" action="${path}/admin/users" method="get">
            <input class="form-control form-dark" name="q" value="${q}" placeholder="Tìm tên hoặc email"/>
            <button class="btn btn-dark" type="submit">Tìm</button>
        </form>
    </div>
    
    <div class="luxe-card p-3">
        <div class="table-responsive">
            <table class="table table-luxe">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Họ tên</th>
                        <th>Email</th>
                        <th>Điện thoại</th>
                        <th>Vai trò</th>
                        <th class="text-end">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${users}" var="u">
                        <tr>
                            <td>${u.userID}</td>
                            <td><b>${u.fullName}</b></td>
                            <td>${u.email}</td>
                            <td>${u.phone}</td>
                            <td>
                                <span class="${u.role=='Admin' ? 'badge-ok' : 'badge-warn'}">${u.role}</span>
                            </td>
                            <td class="text-end">
                                <form method="post" action="${path}/admin/users" class="d-inline">
                                    <input type="hidden" name="action" value="role"/>
                                    <input type="hidden" name="id" value="${u.userID}"/>
                                    <c:set var="newRole" value="${u.role == 'Admin' ? 'Customer' : 'Admin'}" />
                                    <input type="hidden" name="role" value="${newRole}"/>
                                    <button class="btn btn-dark btn-sm">Đặt làm ${newRole}</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
    
    <c:if test="${totalPages > 1}">
      <nav class="mt-4"><ul class="pagination">
        <c:forEach begin="1" end="${totalPages}" var="i">
            <li class="page-item ${i == currentPage ? 'active' : ''}">
                <a class="page-link" href="?page=${i}&q=${q}">${i}</a>
            </li>
        </c:forEach>
      </ul></nav>
    </c:if>

</main>

<jsp:include page="/WEB-INF/admin/includes/admin-footer.jsp"/>