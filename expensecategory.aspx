<%@ Page Language="C#" MasterPageFile="~/MasterPage.Master" AutoEventWireup="true" CodeFile="expensecategory.aspx.cs" Inherits="expensecategory" %>


<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <h3 class="text-primary">Expense Categories</h3>
    <p>View and manage all expense categories.</p>

    <div class="card">
        <div class="card-header">
            <button class="btn btn-primary" id="new">Create New Expense Category</button>
        </div>
       <div class="card-body p-3">
       <div class="table-responsive text-nowrap">
<table class="table" id="ordersTable">
  <thead>
    <tr>
      <th>Name</th>
      <th>Description</th>
      <th>Created At</th>
      <th>Actions</th>
    </tr>
  </thead>
  <tbody class="table-border-bottom-0">
    <tr>
      <td colspan="4">No Data Available</td>
    </tr>
  </tbody>
</table>

</div>

       </div>
    </div>


    <div class="modal fade" id="categoryModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Expense Category</h5>
        <button class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="categoryId" value="0" />
        <div class="mb-3">
          <label class="form-label">Category Name</label>
          <input type="text" id="categoryName" class="form-control" />
        </div>
        <div class="mb-3">
          <label class="form-label">Description</label>
          <textarea id="categoryDescription" class="form-control"></textarea>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
        <button class="btn btn-primary" onclick="saveExpenseCategory()">Save</button>
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
    $("#new").click(() => {
        $("#categoryId").val("0")
        resetControls("#categoryModal")
        $("#categoryModal").modal("show")
    })
    function saveExpenseCategory() {
        const data = {
            CategoryId: parseInt($("#categoryId").val() || 0),
            CategoryName: $("#categoryName").val(),
            Description: $("#categoryDescription").val()
        };

        sendRequest("Api/expense_api.asmx/SaveExpenseCategory", data, (err, res) => {
            if (err || !res.Status) {
                showToast("Failed to save", "error");
                return;
            }

            $("#categoryModal").modal("hide");
            showToast("Category saved!", "success");
            loadExpenseCategories();
        });
    }

    function loadExpenseCategories() {
        const tbody = $("#ordersTable tbody");
        tbody.html(`<tr><td colspan="5">Loading...</td></tr>`);

        sendRequest("Api/expense_api.asmx/GetExpenseCategories", {}, (err, res) => {
            if (err || !res.Status) {
                tbody.html(`<tr><td colspan="5">Failed to load</td></tr>`);
                return;
            }

            const categories = res.Data;
            if (!categories.length) {
                tbody.html(`<tr><td colspan="5">No data available</td></tr>`);
                return;
            }

            let html = "";
            categories.forEach(cat => {
                const encoded = encodeURIComponent(JSON.stringify(cat));
                html += `
            <tr>
                <td>${cat.CategoryName}</td>
                <td>${cat.Description || '-'}</td>
                <td>${cat.CreatedAt}</td>
                <td>
                  <div class="dropdown">
                    <button class="btn p-0 dropdown-toggle hide-arrow" data-bs-toggle="dropdown">
                      <i class="bx bx-dots-vertical-rounded"></i>
                    </button>
                    <ul class="dropdown-menu">
                      <li><a class="dropdown-item" href="javascript:void(0)" onclick="editCategory('${encoded}')"><i class="bx bx-edit-alt me-1"></i> Edit</a></li>
                      <li><a class="dropdown-item" href="javascript:void(0)" onclick="deleteItem('ExpenseCategories', ${cat.CategoryId})"><i class="bx bx-trash me-1"></i> Delete</a></li>
                    </ul>
                  </div>
                </td>
            </tr>`;
            });

            tbody.html(html);
        });
    }

    function editCategory(encoded) {
        const cat = JSON.parse(decodeURIComponent(encoded));
        $("#categoryId").val(cat.CategoryId);
        $("#categoryName").val(cat.CategoryName);
        $("#categoryDescription").val(cat.Description);
        $("#categoryModal").modal("show");
    }

    $(document).ready(() => {
        loadExpenseCategories()
    })

</script>

</asp:Content>