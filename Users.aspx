<%@ Page Language="C#" MasterPageFile="~/MasterPage.Master" AutoEventWireup="true" CodeFile="Users.aspx.cs" Inherits="Users" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <h3 class="text-primary">Users List</h3>
    <p>Here you can manage all system Wide range users.</p>

    <div class="card">
        <div class="card-header">
            <button class="btn btn-primary" id="addNewUser">Add New User</button>
        </div>
       <div class="card-body p-3">
             <div class="table-responsive text-nowrap">
                  <table class="table" id="usersTable">
                    <thead>
                      <tr>
                        <th>Username</th>
                        <th>Emaile</th>
                        <th>Role</th>
                        <th>Actions</th>
                      </tr>
                    </thead>
                    <tbody class="table-border-bottom-0">
                      <tr>
                    <td colspan="4">No Data Avaialble</td>
                      </tr>


                    </tbody>
                  </table>
                </div>
       </div>
    </div>

 <div class="modal fade" id="userModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">User Info</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="userId" />
        <div class="mb-3">
          <label for="username" class="form-label">Username</label>
          <input type="text" id="username" class="form-control" placeholder="e.g., johndoe" />
        </div>
        <div class="mb-3">
          <label for="email" class="form-label">Email</label>
          <input type="email" id="email" class="form-control" placeholder="e.g., john@example.com" />
        </div>
        <div class="mb-3 pass-parent">
          <label for="password" class="form-label">Password</label>
          <input type="password" id="password" class="form-control" placeholder="Enter password" />
        </div>
        <div class="mb-3">
          <label for="role" class="form-label">Role</label>
          <select id="role" class="form-select"></select>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
        <button type="button" class="btn btn-primary" id="saveUserBtn">Save User</button>
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
        var userID = "0"

     

        $("#addNewUser").click(() => {
            userID = "0"
            resetControls("#userModal")
            $(".pass-parent").prop("hidden",false)
            $("#userModal").modal("show")
        })

        $("#saveUserBtn").click(() => {
            const data = {
                UserID: userID,
                Username: $("#username").val().trim(),
                Email: $("#email").val().trim(),
                Password: $("#password").val().trim(),
                RoleID: $("#role").val()
            };

            if (!data.Username || !data.Email || (data.UserID == "0" && data.Password=="") || !data.RoleID || data.RoleID == "0") {
                showToast("All fields are required","error");
                return;
            }

            sendRequest("Api/users_api.asmx/SaveUser", data, (err, res) => {
                if (err || !res.Status) {
                    showToast(res?.Message || "Error saving user","error");
                    return 
                }

                showToast(res.Message,"success")
                $("#userModal").modal("hide");
                loadUsers();
            });
        });

        function editUser(json) {
            const user = JSON.parse(decodeURIComponent(json));
            userID=user.UserID;
            $("#username").val(user.Username);
            $("#email").val(user.Email);
            $("#password").val(""); // clear password for security
            $("#role").val(user.RoleID);
            $(".pass-parent").prop("hidden", true)
            $("#userModal").modal("show");
        }

        function loadUsers() {
            sendRequest("Api/users_api.asmx/GetUsers", {}, function (err, res) {
                if (err || !res.Status) {
                    $("#usersTable tbody").html(`<tr><td colspan="4" class="text-center text-danger">Failed to load users</td></tr>`);
                    return;
                }

                const users = res.Data;
                if (!users || users.length === 0) {
                    $("#usersTable tbody").html(`<tr><td colspan="4" class="text-center text-muted">No users available</td></tr>`);
                    return;
                }

                let html = "";
                users.forEach(user => {
                    const encoded = encodeURIComponent(JSON.stringify(user));
                    html += `
        <tr>
          <td>${user.Username}</td>
          <td>${user.Email}</td>
          <td>${user.RoleName || "N/A"}</td>
          <td>
            <div class="dropdown">
              <button class="btn p-0 dropdown-toggle hide-arrow" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                <i class="bx bx-dots-vertical-rounded"></i>
              </button>
              <ul class="dropdown-menu">
                <li>
                  <a class="dropdown-item" href="javascript:void(0);" onclick="editUser('${encoded}')">
                    <i class="bx bx-edit-alt me-1"></i> Edit
                  </a>
                </li>
                <li>
                  <a class="dropdown-item" href="javascript:void(0);" onclick="deleteItem('Users', ${user.UserID})">
                    <i class="bx bx-trash me-1"></i> Delete
                  </a>
                </li>
              </ul>
            </div>
          </td>
        </tr>`;
                });

                $("#usersTable tbody").html(html);
            });
        }


        $(document).ready(() => {
            loadSelectOptions("role", {
                tableName: "Roles",
                valueColumn: "RoleID",
                textColumn: "RoleName",
                defaultText: "Select Role"
            });

            loadUsers()
        })

    </script>
</asp:Content>