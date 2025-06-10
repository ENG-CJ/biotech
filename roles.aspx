<%@ Page Language="C#" MasterPageFile="~/MasterPage.Master" AutoEventWireup="true" CodeFile="roles.aspx.cs" Inherits="roles" %>


<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <h3 class="text-primary">Roles List</h3>
    <p>Here you can manage all system roles 💾.</p>

    <div class="card">
        <div class="card-header">
            <button class="btn btn-primary" id="addNewRole">Add New Role</button>
        </div>
       <div class="card-body p-3">
             <div class="table-responsive text-nowrap">
                  <table class="table" id="rolesTable">
                    <thead>
                      <tr>
                        <th>Role</th>
                        <th>Description</th>
                        <th>Actions</th>
                      </tr>
                    </thead>
                    <tbody class="table-border-bottom-0">
                      <tr>
                    <td colspan="3">No Data Avaialble</td>
                      </tr>


                    </tbody>
                  </table>
                </div>
       </div>
    </div>

   <div class="modal fade" id="roleModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Role Info</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="roleId" />
        <div class="mb-3">
          <label for="roleName" class="form-label">Role Name</label>
          <input type="text" id="roleName" class="form-control" placeholder="e.g., Admin" />
        </div>
        <div class="mb-3">
          <label for="roleDesc" class="form-label">Description</label>
          <textarea id="roleDesc" class="form-control" rows="3" placeholder="Short description..."></textarea>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
        <button type="button" class="btn btn-primary" id="saveRoleBtn">Save Role</button>
      </div>
    </div>
  </div>
</div>

    <div class="modal fade" id="fullscreenModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-fullscreen" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="modalFullTitle">Assign Permissions</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <div id="permissionContainer" class="row"></div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
        <button type="button" class="btn btn-primary" onclick="savePermissions()">Save Changes</button>
      </div>
    </div>
  </div>
</div>


      <!-- Core JS -->
  <!-- build:js assets/vendor/js/core.js -->
  <script src="assets/vendor/libs/jquery/jquery.js"></script>
  <script src="assets/vendor/libs/popper/popper.js"></script>
  <script src="assets/vendor/js/bootstrap.js"></script>
  <script src="assets/vendor/libs/perfect-scrollbar/perfect-scrollbar.js"></script>

  <script src="assets/vendor/js/menu.js"></script>
  <!-- endbuild -->

  <!-- Vendors JS -->
  <script src="assets/vendor/libs/apex-charts/apexcharts.js"></script>

  <!-- Main JS -->
  <script src="assets/js/main.js"></script>

  <!-- Page JS -->
  <script src="assets/js/dashboards-analytics.js"></script>

  <!-- Place this tag in your head or just before your close body tag. -->
  <script async defer src="https://buttons.github.io/buttons.js"></script>
    <script src="custom_js/utikls.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        var roleID = "0"

        function loadRoles() {
            sendRequest("Api/role_user.asmx/GetRoles", {}, function (err, res) {
                if (err) return alert("Error occurred");

                const { Status, Data, Message } = res;
                if (!Status) return alert(Message);

                let html = "";
                Data.forEach(role => {
                    const encoded = encodeURIComponent(JSON.stringify(role));

                    html += `
                <tr>
                    <td>${role.RoleName}</td>
                    <td>${role.Description}</td>
                    <td>
                        <div class="dropdown">
                            <button class="btn p-0 dropdown-toggle hide-arrow" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="bx bx-dots-vertical-rounded"></i>
                            </button>
                            <ul class="dropdown-menu">
                                <li>
                                    <a class="dropdown-item" href="javascript:void(0);" onclick="editRole('${encoded}')">
                                        <i class="bx bx-edit-alt me-1"></i> Edit
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item" href="javascript:void(0);" onclick="deleteItem('Roles','${role.RoleID}')">
                                        <i class="bx bx-trash me-1"></i> Delete
                                    </a>
                                </li>
                                <li>
  <a class="dropdown-item" href="javascript:void(0);" onclick="assignPermissions(${role.RoleID}, '${role.RoleName}')">
    <i class="bx bx-key me-1"></i> Assign Permissions
  </a>
</li>

                            </ul>
                        </div>
                    </td>
                </tr>`;
                });

                $("#rolesTable tbody").html(html);

                // No need to manually initialize dropdowns; Bootstrap 5 handles them automatically
            });
        }



        $("#addNewRole").click(() => {
            roleID = "0"
            resetControls("#roleModal")
            $("#roleModal").modal("show")
        })

        function assignPermissions(roleId, roleName) {
            $("#modalFullTitle").text("Permissions for: " + roleName);
            $("#fullscreenModal").modal("show");
            $("#permissionContainer").html('<div class="text-center w-100">Loading...</div>');

            sendRequest("Api/role_user.asmx/GetPermissionsByRole", { roleId }, function (err, res) {
                if (err || !res.Status) {
                    $("#permissionContainer").html('<div class="text-danger text-center w-100">Failed to load permissions.</div>');
                    return;
                }

                const data = res.Data;
                if (!data || data.length === 0) {
                    $("#permissionContainer").html('<div class="text-muted text-center w-100">No data available.</div>');
                    return;
                }

                let html = "";
                data.forEach(group => {
                    const mainId = `main-${group.MainMenuID}`;
                    const allChecked = group.Menus.every(m => m.CanView);

                    html += `
            <div class="card mb-3 col-4">
                <div class="card-header bg-label-primary d-flex justify-content-between align-items-center">
                    <strong>
                      <i class="${group.IconClass} me-2"></i>${group.MainMenuName}
                    </strong>
                    <div class="form-check form-switch m-0">
                        <input type="checkbox" class="form-check-input main-toggle" data-main="${group.MainMenuID}" id="${mainId}" ${allChecked ? 'checked' : ''}>
                    </div>
                </div>
                <div class="card-body row">`;

                    group.Menus.forEach(menu => {
                        const checked = menu.CanView ? "checked" : "";
                        html += `
                <div class="form-check form-switch col-md-6 mb-2">
                    <input type="checkbox" class="form-check-input menu-toggle" data-main="${group.MainMenuID}" data-menu="${menu.MenuID}" id="menu-${menu.MenuID}" ${checked}>
                    <label class="form-check-label" for="menu-${menu.MenuID}">${menu.MenuName}</label>
                </div>`;
                    });

                    html += `</div></div>`;
                });

                $("#permissionContainer").html(html);
                $("#fullscreenModal").data("roleid", roleId);

                bindPermissionToggles();
            });
        }
        function bindPermissionToggles() {
            // Toggle all children when main menu toggled
            $(".main-toggle").on("change", function () {
                const mainId = $(this).data("main");
                const checked = $(this).is(":checked");
                $(`.menu-toggle[data-main='${mainId}']`).prop("checked", checked);
            });

            // If any child changes, update main accordingly
            $(".menu-toggle").on("change", function () {
                const mainId = $(this).data("main");
                const $all = $(`.menu-toggle[data-main='${mainId}']`);
                const $main = $(`.main-toggle[data-main='${mainId}']`);
                const allChecked = $all.length === $all.filter(":checked").length;
                $main.prop("checked", allChecked);
            });
        }

        function savePermissions() {
            const roleId = $("#fullscreenModal").data("roleid");
            const permissions = [];

            $(".menu-toggle").each(function () {
                const menuId = $(this).data("menu");
                const canView = $(this).is(":checked");
                permissions.push({ MenuID: menuId, CanView: canView });
            });

            sendRequest("Api/role_user.asmx/SavePermissions", { RoleID: roleId, Permissions: permissions }, function (err, res) {
                if (err || !res.Status) {
                    showToast(res?.Message || "Save failed","error");
                    return;
                }

                showToast("Permissions saved successfully","success");
                $("#fullscreenModal").modal("hide");
            });
        }




        $(document).ready(() => {
            $("#saveRoleBtn").click(function () {
              
                const roleName = $("#roleName").val().trim();
                const roleDesc = $("#roleDesc").val().trim();

                if (!roleName || !roleDesc) {
                    showToast("Please fill all required fields.","error");
                    return;
                }

                const payload = {
                    RoleID: roleID,
                    RoleName: roleName,
                    Description: roleDesc
                };

                sendRequest("Api/role_user.asmx/InsertRole",payload, function (error, response) {
                    if (error) {
                        showToast("Error: " + error,"error");
                        return;
                    }

                    const { Status, Message } = response;
                    if (Status) {
                        $("#roleModal").modal("hide");
                        showToast(Message,"success");
                        loadRoles()
                    } else {
                        showToast("Server error Occurred: " + Message,"error");
                    }
                });
            });

            loadRoles()
        })

        function editRole(encoded) {
            const role = JSON.parse(decodeURIComponent(encoded));
            roleID = role.RoleID;
            $("#roleName").val(role.RoleName);
            $("#roleDesc").val(role.Description);
            $("#roleModal").modal("show");
        }

    </script>
</asp:Content>