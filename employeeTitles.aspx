<%@ Page Language="C#" MasterPageFile="~/MasterPage.Master" AutoEventWireup="true" CodeFile="employeeTitles.aspx.cs" Inherits="employeeTitles" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <h3 class="text-primary">Manage Employee Titles</h3>
    <p>Here you can manage all Employee Profissions.</p>

    <div class="card">
        <div class="card-header">
            <button class="btn btn-primary" id="addNew">Add New Title</button>
        </div>
       <div class="card-body p-3">
             <div class="table-responsive text-nowrap">
               <table class="table" id="employeeTitlesTable">
  <thead>
    <tr>
      <th>Title Name</th>
      <th>Notes</th>
      <th>Actions</th>
    </tr>
  </thead>
  <tbody class="table-border-bottom-0">
    <tr>
      <td colspan="3">No Data Available</td>
    </tr>
  </tbody>
</table>

                </div>
       </div>
    </div>




<div class="modal fade" id="employeeTitleModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-md" role="document">
    <div class="modal-content">

      <div class="modal-header">
        <h5 class="modal-title">
          <i class="fa fa-user-tie me-2"></i> Employee Title Info
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>

      <div class="modal-body">
        <input type="hidden" id="titleId" />

        <div class="mb-3">
          <label for="titleName" class="form-label">Title Name</label>
          <input type="text" class="form-control" id="titleName" placeholder="e.g., Store Manager" required />
        </div>

        <div class="mb-3">
          <label for="titleNotes" class="form-label">Notes</label>
          <textarea class="form-control" id="titleNotes" rows="2" placeholder="Optional notes about this title"></textarea>
        </div>
      </div>

      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="button" class="btn btn-primary" onclick="saveEmployeeTitle()">Save Title</button>
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

        $("#addNew").click(() => {
            $("#titleId").val("0");
            resetControls("#employeeTitleModal")
            $("#employeeTitleModal").modal("show");
        })
        function loadEmployeeTitles() {
            sendRequest("Api/Employee_api.asmx/GetEmployeeTitles", {}, (err, res) => {
                const tbody = $("#employeeTitlesTable tbody");
                if (err || !res.Status) {
                    tbody.html(`<tr><td colspan="4">Failed to load</td></tr>`);
                    return;
                }

                const data = res.Data;
                if (!data.length) {
                    tbody.html(`<tr><td colspan="4">No Titles Found</td></tr>`);
                    return;
                }

                let html = "";
                data.forEach(title => {
                    const encoded = encodeURIComponent(JSON.stringify(title));

                    html += `
                <tr>
                    <td>${title.TitleName}</td>
                    <td>${title.Notes || '-'}</td>
                    <td>${title.CreatedAt}</td>
                    <td>
                        <div class="dropdown">
                            <button class="btn p-0 dropdown-toggle hide-arrow" data-bs-toggle="dropdown">
                                <i class="bx bx-dots-vertical-rounded"></i>
                            </button>
                            <ul class="dropdown-menu">
                                <li><a class="dropdown-item" onclick="editTitle('${encoded}')"><i class="bx bx-edit-alt me-1"></i> Edit</a></li>
                                <li><a class="dropdown-item" onclick="deleteItem('EmployeeTitles', '${title.TitleId}')"><i class="bx bx-trash me-1"></i> Delete</a></li>
                            </ul>
                        </div>
                    </td>
                </tr>
            `;
                });

                tbody.html(html);
            });
        }
        function saveEmployeeTitle() {
            const data = {
                TitleId: $("#titleId").val() || 0,
                TitleName: $("#titleName").val().trim(),
                Notes: $("#titleNotes").val().trim()
            };

            if (!data.TitleName) {
                showToast("Title name is required", "warning");
                return;
            }

            sendRequest("Api/Employee_api.asmx/SaveEmployeeTitle", data, (err, res) => {
                if (err || !res.Status) {
                    showToast(res?.Message || "Failed to save", "error");
                    return;
                }

                $("#employeeTitleModal").modal("hide");
                loadEmployeeTitles();
                showToast("Title saved successfully", "success");
            });
        }
        function editTitle(encoded) {
            const title = JSON.parse(decodeURIComponent(encoded));
            $("#titleId").val(title.TitleId);
            $("#titleName").val(title.TitleName);
            $("#titleNotes").val(title.Notes);
            $("#employeeTitleModal").modal("show");
        }


        $(document).ready(() => {
            loadEmployeeTitles()
        })
    </script>
</asp:Content>
