<%@ Page Language="C#" MasterPageFile="~/MasterPage.Master" AutoEventWireup="true" CodeFile="stock.aspx.cs" Inherits="stock" %>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <h3 class="text-primary">In Stock Product</h3>
    <p>Here you can view all in-stock products and inventory-availability.</p>

    <div class="card">
        <div class="card-header">
            <button class="btn btn-primary" id="download">Download PDF</button>
        </div>
       <div class="card-body p-3">
             <div class="table-responsive text-nowrap">
               <table class="table" id="productsTable">
  <thead>
    <tr>
      <th>SQN</th>
      <th>Product</th>
      <th>Category</th>
      <th>Cost</th>
      <th>Price</th>
      <th>Qty</th>
      <th>Status</th>
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
    function loadInventory() {
        sendRequest("Api/inventory_api.asmx/GetInventoryReport", {}, function (err, res) {
            if (err || !res.Status) {
                $("#productsTable tbody").html('<tr><td colspan="7" class="text-danger text-center">Failed to load inventory</td></tr>');
                return;
            }

            const items = res.Data;
            if (!items.length) {
                $("#productsTable tbody").html('<tr><td colspan="7" class="text-muted text-center">No inventory data available</td></tr>');
                return;
            }

            let html = "";
            items.forEach(p => {
                html += `
        <tr>
          <td>${p.ProductID}</td>
          <td>${p.ProductName}</td>
          <td>${p.CategoryName || '-'}</td>
          <td>$${parseFloat(p.CostPrice).toFixed(2)}</td>
          <td>$${parseFloat(p.SellingPrice).toFixed(2)}</td>
          <td>${parseFloat(p.QuantityInStock).toFixed(2)}</td>
          <td>
            ${p.Status ? '<span class="badge bg-success">Active</span>' : '<span class="badge bg-danger">Inactive</span>'}
          </td>
        </tr>`;
            });

            $("#productsTable tbody").html(html);
        });
    }

    $(document).ready(() => {
        loadInventory()
    })

</script>
</asp:Content>
