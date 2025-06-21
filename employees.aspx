<%@ Page Language="C#" MasterPageFile="~/MasterPage.Master" AutoEventWireup="true" CodeFile="employees.aspx.cs" Inherits="employees" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <h3 class="text-primary">Manage Employees</h3>
    <p>Here you can manage all Employees.</p>

    <div class="card">
        <div class="card-header">
            <button class="btn btn-primary" id="addNew">Add New Employee</button>
        </div>
       <div class="card-body p-3">
             <div class="table-responsive text-nowrap">
            <!-- ✅ Employee Table -->
<table class="table" id="employeesTable">
  <thead>
    <tr>
      <th>#</th>
      <th>Name</th>
      <th>Phone</th>
      <th>Email</th>
      <th>Title</th>
      <th>Actions</th>
    </tr>
  </thead>
  <tbody class="table-border-bottom-0">
    <tr><td colspan="5">No Data Available</td></tr>
  </tbody>
</table>

                </div>
       </div>
    </div>



    <!-- ✅ Employee Registration Modal -->
<div class="modal fade" id="employeeModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">
          <i class="fa fa-user-tie me-1"></i> Employee Registration
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="employeeId">

        <div class="row">
          <div class="col-md-6 mb-3">
            <label class="form-label">Full Name</label>
            <input type="text" id="fullName" class="form-control" required />
          </div>
          <div class="col-md-6 mb-3">
            <label class="form-label">Phone</label>
            <input type="text" id="phone" class="form-control" />
          </div>

          <div class="col-md-6 mb-3">
            <label class="form-label">Email</label>
            <input type="email" id="email" class="form-control" />
          </div>
          <div class="col-md-6 mb-3">
            <label class="form-label">Title</label>
            <select id="titleId" class="form-select"></select>
          </div>

          <div class="col-md-12 mb-3">
            <label class="form-label">Address</label>
            <textarea id="address" class="form-control" rows="2"></textarea>
          </div>
        </div>
      </div>

      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button class="btn btn-primary" onclick="saveEmployee()">
          <i class="fa fa-save me-1"></i> Save Employee
        </button>
      </div>
    </div>
  </div>
</div>


    <div class="modal fade" id="salaryModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">
          <i class="fa fa-money-bill me-1"></i> Salary Configuration
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>

      <div class="modal-body">
        <div class="alert alert-primary">
          Configuring salary for: <strong id="salaryEmpName">Employee Name</strong>
        </div>

        <input type="hidden" id="salaryId" />
        <input type="hidden" id="salaryEmpId" />

        <div class="row">
          <div class="col-md-4 mb-3">
            <label class="form-label">Basic Salary</label>
            <input type="number" id="basicSalary" class="form-control" required />
          </div>
          <div class="col-md-4 mb-3">
            <label class="form-label">Allowance</label>
            <input type="number" id="allowance" class="form-control" value="0" />
          </div>
          <div class="col-md-4 mb-3">
            <label class="form-label">Deductions</label>
            <input type="number" id="deductions" class="form-control" value="0" />
          </div>
        </div>

        <div class="mb-3">
          <label class="form-label">Notes</label>
          <textarea id="salaryNotes" class="form-control" rows="3" placeholder="Optional notes..."></textarea>
        </div>
      </div>

      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
        <button class="btn btn-primary" onclick="saveEmployeeSalary()">
          <i class="fa fa-save me-1"></i> Save Salary
        </button>
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

      function openSalarySetup(empId, empName) {
          $("#salaryEmpId").val(empId);
          $("#salaryEmpName").text(empName);
          $("#salaryId").val(""); // default new setup
          $("#basicSalary, #allowance, #deductions, #salaryNotes").val(""); // clear

          sendRequest("Api/HR_api.asmx/GetEmployeeSalaries", {}, (err, res) => {
              if (!err && res.Status) {
                  const salary = res.Data.find(s => s.EmployeeId === empId);
                  if (salary) {
                      $("#salaryId").val(salary.SalaryId);
                      $("#basicSalary").val(salary.BasicSalary);
                      $("#allowance").val(salary.Allowance);
                      $("#deductions").val(salary.Deductions);
                      $("#salaryNotes").val(salary.Notes);
                  }
              }

              $("#salaryModal").modal("show");
          });
      }

      function saveEmployeeSalary() {
          const data = {
              SalaryId: $("#salaryId").val() || 0,
              EmployeeId: $("#salaryEmpId").val(),
              BasicSalary: parseFloat($("#basicSalary").val()),
              Allowance: parseFloat($("#allowance").val()) || 0,
              Deductions: parseFloat($("#deductions").val()) || 0,
              Notes: $("#salaryNotes").val()
          };

          sendRequest("Api/HR_api.asmx/SaveEmployeeSalary", { data }, (err, res) => {
              if (err || !res.Status) {
                  showToast(res.Message || "Failed to save", "error");
                  return;
              }

              $("#salaryModal").modal("hide");
              showToast("Salary saved!", "success");
          });
      }



      $("#addNew").click(() => {
          $("#employeeId").val("0")
          resetControls("#employeeModal")
          $("#employeeModal").modal("show");

      })
      function loadEmployeeTitlesDropdown() {
          loadSelectOptions("titleId", {
              tableName: "EmployeeTitles",
              valueColumn: "TitleId",
              textColumn: "TitleName",
              defaultText: "Select Title"
          });
      }

      function saveEmployee() {
          const data = {
              EmployeeId: $("#employeeId").val() || 0,
              FullName: $("#fullName").val(),
              Phone: $("#phone").val(),
              Email: $("#email").val(),
              TitleId: $("#titleId").val(),
              Address: $("#address").val()
          };

          if (!data.FullName || !data.TitleId) {
              showToast("Full Name and Title are required", "error");
              return;
          }

          sendRequest("Api/Employee_api.asmx/RegisterEmployee", { employeeData: data }, (err, res) => {
              if (err || !res.Status) {
                  showToast("Failed to save employee", "error");
                  return;
              }

              $("#employeeModal").modal("hide");
              loadEmployees();
              showToast("Employee saved successfully", "success");
          });
      }

      function loadEmployees() {
          const tbody = $("#employeesTable tbody");
          tbody.html(`<tr><td colspan="5">Loading...</td></tr>`);

          sendRequest("Api/Employee_api.asmx/GetAllEmployees", {}, (err, res) => {
              if (err || !res.Status) {
                  tbody.html(`<tr><td colspan="5">Failed to load data</td></tr>`);
                  return;
              }

              const employees = res.Data;
              if (!employees.length) {
                  tbody.html(`<tr><td colspan="5">No data available</td></tr>`);
                  return;
              }

              let html = "";
              employees.forEach(emp => {
                  const encoded = encodeURIComponent(JSON.stringify(emp));
                  html += `
        <tr>
          <td>${emp.EmpId}</td>
          <td>${emp.FullName}</td>
          <td>${emp.Phone}</td>
          <td>${emp.Email}</td>
          <td>${emp.Title}</td>
          <td>
            <div class="dropdown">
              <button class="btn p-0 dropdown-toggle hide-arrow" data-bs-toggle="dropdown">
                <i class="bx bx-dots-vertical-rounded"></i>
              </button>
              <ul class="dropdown-menu">
                <li>
                  <a class="dropdown-item" href="javascript:void(0);" onclick="editEmployee('${encoded}')">
                    <i class="bx bx-edit-alt me-1"></i> Edit
                  </a>
                </li>
                <li>
                  <a class="dropdown-item" href="javascript:void(0);" onclick="deleteItem('Employees','${emp.EmployeeId}')">
                    <i class="bx bx-trash me-1"></i> Delete
                  </a>
                </li>
               <li>
  <a class="dropdown-item" href="javascript:void(0);" onclick="openSalarySetup('${emp.EmployeeId}', '${emp.FullName}')">
    <i class="fa fa-dollar-sign me-1"></i> Salary Setup
  </a>
</li>

              </ul>
            </div>
          </td>
        </tr>
      `;
              });

              tbody.html(html);
          });
      }

      function editEmployee(encoded) {
          const emp = JSON.parse(decodeURIComponent(encoded));
          $("#employeeId").val(emp.EmployeeId);
          $("#fullName").val(emp.FullName);
          $("#phone").val(emp.Phone);
          $("#email").val(emp.Email);
          $("#titleId").val(emp.TitleId);
          $("#address").val(emp.Address);
          $("#employeeModal").modal("show");
      }

      $(document).ready(() => {
          loadEmployeeTitlesDropdown();
          loadEmployees();
      });
</script>

</asp:Content>