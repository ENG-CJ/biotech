<%@ Page Language="C#" MasterPageFile="~/MasterPage.Master" AutoEventWireup="true" CodeFile="products.aspx.cs" Inherits="products" %>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <h3 class="text-primary">Product</h3>
    <p>Here you can manage all products Wide range.</p>

    <div class="card">
        <div class="card-header">
            <button class="btn btn-primary" id="addNewProduct">Creare New Product</button>
        </div>
       <div class="card-body p-3">
             <div class="table-responsive text-nowrap">
               <table class="table" id="productsTable">
  <thead>
    <tr>
      <th>Product</th>
      <th>Category</th>
      <th>Cost</th>
      <th>Price</th>
      <th>Qty</th>
      <th>Status</th>
      <th>Actions</th>
    </tr>
  </thead>
  <tbody class="table-border-bottom-0">
    <tr>
      <td colspan="7">No Data Available</td>
    </tr>
  </tbody>
</table>

                </div>
       </div>
    </div>

<div class="modal fade" id="productModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Product</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>

      <div class="modal-body">
        <input type="hidden" id="productId" />

        <div class="row">
          <div class="col-md-6 mb-3">
            <label for="productName" class="form-label required-label">Product Name</label>
            <input type="text" id="productName" class="form-control" placeholder="Product name" required />
          </div>

          <div class="col-md-6 mb-3">
            <label for="productCode" class="form-label">Product Code</label>
            <input type="text" id="productCode" class="form-control" placeholder="Optional code" />
          </div>

          <div class="col-md-6 mb-3">
            <label for="categoryId" class="form-label">Category</label>
            <select id="categoryId" class="form-select"></select>
          </div>

          <div class="col-md-6 mb-3">
            <label for="brand" class="form-label">Brand</label>
            <input type="text" id="brand" class="form-control" placeholder="Brand name" />
          </div>

          <div class="col-md-6 mb-3">
            <label for="unit" class="form-label">Unit</label>
            <input type="text" id="unit" class="form-control" placeholder="e.g. Box, Piece" />
          </div>

          <div class="col-md-6 mb-3">
            <label for="barcode" class="form-label">Barcode</label>
            <input type="text" id="barcode" class="form-control" placeholder="Scan or enter barcode" />
          </div>

          <div class="col-md-6 mb-3">
            <label for="costPrice" class="form-label required-label">Cost Price</label>
            <input type="number" id="costPrice" class="form-control" min="0" />
          </div>

          <div class="col-md-6 mb-3">
            <label for="sellingPrice" class="form-label required-label">Selling Price</label>
            <input type="number" id="sellingPrice" class="form-control" min="0" />
          </div>

          <div class="col-md-6 mb-3">
            <label for="expiryDate" class="form-label">Expiry Date</label>
            <input type="date" id="expiryDate" class="form-control" />
          </div>

        <div class="col-md-6 mb-3">
  <label for="status" class="form-label d-block">
    Status
    <i class="bx bx-info-circle text-primary" data-bs-toggle="tooltip" title="Toggle to activate or deactivate this product. Inactive products will not be available for sale."></i>
  </label>
  <div class="form-check form-switch">
    <input type="checkbox" class="form-check-input" id="status" checked />
    <label class="form-check-label" for="status">Active</label>
  </div>
</div>


       <div class="col-md-6 mb-3">
  <label class="form-label d-block">
    Has Initial Quantity
    <i class="bx bx-info-circle text-primary" data-bs-toggle="tooltip" title="If enabled, this product will be added to inventory and made available for sale."></i>
  </label>
  <div class="form-check form-switch">
    <input type="checkbox" class="form-check-input" id="hasInitialQty" onchange="toggleQuantity()" />
    <label class="form-check-label" for="hasInitialQty">Enable</label>
  </div>
</div>


          <div class="col-md-6 mb-3 d-none" id="quantitySection">
            <label for="quantity" class="form-label">Initial Quantity</label>
            <input type="number" id="quantity" class="form-control" min="0" />
          </div>

          <div class="col-md-12 mb-3">
            <label for="description" class="form-label">Description</label>
            <textarea id="description" class="form-control" rows="2" placeholder="Optional description..."></textarea>
          </div>

          <div class="col-md-12 mb-3">
            <label for="notes" class="form-label">Notes</label>
            <textarea id="notes" class="form-control" rows="2" placeholder="Any notes..."></textarea>
          </div> 
            <div class="col-md-12 mb-3">
          <div class="">
  <label for="reorderLevel" class="form-label">Reorder Level</label>
  <input type="number" id="reorderLevel" class="form-control" placeholder="e.g., 10" />
</div>

          </div>
        </div>
      </div>

      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
        <button type="button" class="btn btn-primary" onclick="saveProduct()">Save Changes</button>
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

    var product_id="0"
    $("#addNewProduct").click(() => {
        document.getElementById("hasInitialQty").checked = false;
        toggleQuantity()
        product_id="0"
        resetControls("#productModal")
        $("#productModal").modal("show")
    })
    function toggleQuantity() {
        const isChecked = document.getElementById("hasInitialQty").checked;
        document.getElementById("quantitySection").classList.toggle("d-none", !isChecked);
    }

    function loadProducts() {
        sendRequest("Api/inventory_api.asmx/GetProducts", {}, function (err, res) {
            if (err || !res.Status) {
                $("#productsTable tbody").html('<tr><td colspan="7" class="text-danger text-center">Failed to load products</td></tr>');
                return;
            }

            const data = res.Data;
            if (!data.length) {
                $("#productsTable tbody").html('<tr><td colspan="7" class="text-muted text-center">No products found</td></tr>');
                return;
            }

            let html = "";
            data.forEach(p => {
                const encoded = encodeURIComponent(JSON.stringify(p));
                html += `
        <tr>
          <td>${p.ProductName}</td>
          <td>${p.CategoryName || "N/A"}</td>
          <td>$${p.CostPrice}</td>
          <td>$${p.SellingPrice}</td>
          <td>${p.Quantity ?? 0}</td>
          <td><span class="badge bg-${p.Status ? 'success' : 'secondary'}">${p.Status ? 'Active' : 'Inactive'}</span></td>
          <td>
            <div class="dropdown">
              <button type="button" class="btn p-0 dropdown-toggle hide-arrow" data-bs-toggle="dropdown">
                <i class="bx bx-dots-vertical-rounded"></i>
              </button>
              <div class="dropdown-menu">
                <a class="dropdown-item" href="javascript:void(0);" onclick="editProduct('${encoded}')">
                  <i class="bx bx-edit-alt me-1"></i> Edit
                </a>
                <a class="dropdown-item" href="javascript:void(0);" onclick="deleteItem('Products', ${p.ProductID}, loadProducts)">
                  <i class="bx bx-trash me-1"></i> Delete
                </a>
              </div>
            </div>
          </td>
        </tr>
      `;
            });

            $("#productsTable tbody").html(html);
        });
    }


    function saveProduct() {
        const data = {
            ProductID: product_id,
            ProductName: $("#productName").val(),
            ProductCode: $("#productCode").val() || null,
            Description: $("#description").val() || null,
            Unit: $("#unit").val() || null,
            CategoryID: $("#categoryId").val() || null,
            Brand: $("#brand").val() || null,
            CostPrice: parseFloat($("#costPrice").val() || 0),
            SellingPrice: parseFloat($("#sellingPrice").val() || 0),
            HasInitialQty: $("#hasInitialQty").prop("checked"),
            Quantity: $("#hasInitialQty").prop("checked") ? parseFloat($("#quantity").val() || 0) : null,
            ExpiryDate: $("#expiryDate").val() || null,
            Barcode: $("#barcode").val() || null,
            Status: $("#status").prop("checked"),
            Notes: $("#notes").val() || null,
            ReorderLevel: $("#reorderLevel").val()
        };

        sendRequest("Api/inventory_api.asmx/SaveProduct", { product: data }, function (err, res) {
            if (err || !res.Status) return showToast(res?.Message || "Error saving product", "error");

            showToast("Product saved successfully", "success");
            $("#productModal").modal("hide");
            loadProducts(); // Assume exists
        });
    }

  
    function editProduct(encoded) {
        const p = JSON.parse(decodeURIComponent(encoded));

        product_id=p.ProductID;
        $("#productName").val(p.ProductName);
        $("#reorderLevel").val(p.reorderLevel ?? "");

        $("#productCode").val(p.ProductCode);
        $("#categoryId").val(p.CategoryID);
        $("#brand").val(p.Brand);
        $("#unit").val(p.Unit);
        $("#barcode").val(p.Barcode);
        $("#costPrice").val(p.CostPrice);
        $("#sellingPrice").val(p.SellingPrice);
        $("#expiryDate").val(p.ExpiryDate?.split('T')[0] || "");
        $("#status").prop("checked", p.Status);
        $("#description").val(p.Description);
        $("#notes").val(p.Notes);

        const hasQty = p.HasInitialQty;
        $("#hasInitialQty").prop("checked", hasQty);
        toggleQuantity();
        if (hasQty) {
            $("#quantity").val(p.Quantity);
        }

        $("#productModal").modal("show");
    }


    $(document).ready(() => {
        loadSelectOptions("categoryId", {
            tableName: "categories",
            valueColumn: "CategoryID",
            textColumn: "CategoryName",
            defaultText: "Select Category"
        });
        loadProducts()
    })

</script>
</asp:Content>
