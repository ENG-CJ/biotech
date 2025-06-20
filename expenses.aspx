<%@ Page Language="C#" MasterPageFile="~/MasterPage.Master" AutoEventWireup="true" CodeFile="expenses.aspx.cs" Inherits="expenses" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <h3 class="text-primary">Expenses</h3>
    <p>View and manage all expenses.</p>

    <div class="card">
        <div class="card-header">
            <button class="btn btn-primary" id="newExpense">Create New Expense</button>
        </div>
       <div class="card-body p-3">
       <div class="table-responsive text-nowrap">
<table class="table" id="expensesTable">
  <thead>
    <tr>
      <th>Category</th>
      <th>Amount</th>
      <th>Description</th>
      <th>Date</th>
      <th>Actions</th>
    </tr>
  </thead>
  <tbody class="table-border-bottom-0">
    <tr>
      <td colspan="5">No Data Available</td>
    </tr>
  </tbody>
</table>


</div>

       </div>
    </div>


<div class="modal fade" id="expenseModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">New Expense</h5>
        <button class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="expenseId" value="0" />
        <div class="mb-3">
          <label>Category</label>
          <select id="expenseCategory" class="form-select"></select>
        </div>
        <div class="mb-3">
          <label>Amount</label>
          <input type="number" id="expenseAmount" class="form-control" />
        </div>
        <div class="mb-3">
          <label>Description</label>
          <textarea id="expenseDescription" class="form-control"></textarea>
        </div>
        <div class="mb-3">
          <label>Date</label>
          <input type="date" id="expenseDate" class="form-control" />
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
        <button class="btn btn-primary" onclick="saveExpense()">Save</button>
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
    $("#newExpense").click(() => {
        $("#expenseId").val("0")
        resetControls("#expenseModal")
        $("#expenseModal").modal("show")
    })
    function saveExpense() {
        const data = {
            ExpenseId: parseInt($("#expenseId").val() ||0),
            ExpenseCategoryId: $("#expenseCategory").val(),
            Amount: parseFloat($("#expenseAmount").val()),
            Description: $("#expenseDescription").val(),
            ExpenseDate: $("#expenseDate").val()
        };

        sendRequest("Api/Expense_api.asmx/SaveExpense", data, (err, res) => {
            if (err || !res.Status) {
                showToast("Save failed", "error");
                return;
            }

            $("#expenseModal").modal("hide");
            showToast("Saved successfully", "success");
            loadExpenses();
        });
    }

    function editExpense(encoded) {
        const exp = JSON.parse(decodeURIComponent(encoded));
        $("#expenseId").val(exp.ExpenseId);
        $("#expenseCategory").val(exp.category);
        console.log(exp)
        $("#expenseAmount").val(exp.Amount);
        $("#expenseDescription").val(exp.Description);
        $("#expenseDate").val(exp.ExpenseDate);
        $("#expenseModal").modal("show");
    }

    function loadExpenses() {
        const tbody = $("#expensesTable tbody");
        tbody.html(`<tr><td colspan="5">Loading...</td></tr>`);

        sendRequest("Api/Expense_api.asmx/GetAllExpenses", {}, (err, res) => {
            if (err || !res.Status) {
                tbody.html(`<tr><td colspan="5">Failed to load</td></tr>`);
                return;
            }

            const list = res.Data;
            if (!list.length) {
                tbody.html(`<tr><td colspan="5">No data available</td></tr>`);
                return;
            }

            let html = "";
            list.forEach(e => {
                const encoded = encodeURIComponent(JSON.stringify(e));
                html += `
            <tr>
                <td>${e.CategoryName}</td>
                <td>$${parseFloat(e.Amount).toFixed(2)}</td>
                <td>${e.Description || '-'}</td>
                <td>${e.ExpenseDate}</td>
                <td>
                    <div class="dropdown">
                        <button class="btn p-0 dropdown-toggle hide-arrow" data-bs-toggle="dropdown">
                            <i class="bx bx-dots-vertical-rounded"></i>
                        </button>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="javascript:void(0);" onclick="editExpense('${encoded}')"><i class="bx bx-edit-alt me-1"></i> Edit</a></li>
                            <li><a class="dropdown-item" href="javascript:void(0);" onclick="deleteItem('Expenses', ${e.ExpenseId})"><i class="bx bx-trash me-1"></i> Delete</a></li>
                        </ul>
                    </div>
                </td>
            </tr>`;
            });

            tbody.html(html);
        });
    }


    $(document).ready(() => {
        loadExpenses()

        loadSelectOptions("expenseCategory", {
            tableName: "ExpenseCategories",
            valueColumn: "CategoryId",
            textColumn: "CategoryName",
            defaultText: "Select Category"
        });
    })

</script>

</asp:Content>
