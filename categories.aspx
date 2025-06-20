<%@ Page Language="C#" MasterPageFile="~/MasterPage.Master" AutoEventWireup="true" CodeFile="categories.aspx.cs" Inherits="categories" %>


<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <h3 class="text-primary">Categories List</h3>
    <p>Here you can manage all categories.</p>

    <div class="card">
        <div class="card-header">
            <button class="btn btn-primary" id="addNewCategory">Create New Category</button>
        </div>
       <div class="card-body p-3">
            <div class="table-responsive text-nowrap">
  <table class="table" id="categoriesTable">
    <thead>
      <tr>
        <th>Category Name</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody class="table-border-bottom-0">
      <tr><td colspan="2">No Data Available</td></tr>
    </tbody>
  </table>
</div>

       </div>
    </div>

<div class="modal fade" id="categoryModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Category Info</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="categoryId" />
        <div class="mb-3">
          <label for="categoryName" class="form-label">Category Name</label>
          <input type="text" id="categoryName" class="form-control" placeholder="e.g., Medicines" required />
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
        <button type="button" class="btn btn-primary" id="saveCategoryBtn">Save Category</button>
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
        var cat_id = "0"

     

        $("#addNewCategory").click(() => {
            cat_id = "0"
            resetControls("#categoryModal")
            $(".pass-parent").prop("hidden",false)
            $("#categoryModal").modal("show")
        })
        function loadCategories() {
            sendRequest("Api/inventory_api.asmx/GetAllCategories", {}, function (err, res) {
                if (err || !res.Status) {
                    $("#categoriesTable tbody").html('<tr><td colspan="2" class="text-center text-danger">Failed to load</td></tr>');
                    return;
                }

                const data = res.Data;
                if (!data.length) {
                    $("#categoriesTable tbody").html('<tr><td colspan="2" class="text-center text-muted">No Data Available</td></tr>');
                    return;
                }

                let html = "";
                data.forEach(c => {
                    html += `
            <tr>
              <td>${c.CategoryName}</td>
              <td>
                <button class="btn btn-sm btn-primary" onclick="editCategory(${c.CategoryID}, '${c.CategoryName}')"><i class="bx bx-edit"></i></button>
                <button class="btn btn-sm btn-danger ms-2" onclick="deleteItem('Categories', ${c.CategoryID}, loadCategories)"><i class="bx bx-trash"></i></button>
              </td>
            </tr>`;
                });

                $("#categoriesTable tbody").html(html);
            });
        }


        function editCategory(id, name) {
           cat_id=id;
            $("#categoryName").val(name);
            $("#categoryModal").modal("show");
        }

        $("#saveCategoryBtn").on("click", function () {
            const data = {
                CategoryID: cat_id,
                CategoryName: $("#categoryName").val().trim()
            };

            if (!data.CategoryName) {
                showToast("Category name is required", "error");
                return;
            }

            sendRequest("Api/inventory_api.asmx/SaveOrUpdateCategory", { data }, function (err, res) {
                if (err || !res.Status) {
                    showToast(res?.Message || "Save failed", "error");
                    return;
                }

                showToast("Category saved successfully");
                $("#categoryModal").modal("hide");
                loadCategories();
            });
        });

        $(document).ready(() => {
            loadCategories()
        })

    </script>
</asp:Content>
