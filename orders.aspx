<%@ Page Language="C#" MasterPageFile="~/MasterPage.Master" AutoEventWireup="true" CodeFile="orders.aspx.cs" Inherits="orders" %>



<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <h3 class="text-primary">Product Orders</h3>
    <p>View and manage all product orders.</p>

    <div class="card">
        <div class="card-header">
            <button class="btn btn-primary" id="placeorder">Place order</button>
        </div>
       <div class="card-body p-3">
       <div class="table-responsive text-nowrap">
  <table class="table" id="ordersTable">
    <thead>
      <tr>
        <th>Product</th>
          <th>Supplier</th>
        <th>Quantity</th>
        <th>Unit Price</th>
        <th>Total</th>
        <th>Status</th>
        <th>Ordered By</th>
        <th>Date</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody class="table-border-bottom-0">
      <tr>
        <td colspan="9">No Data Available</td>
      </tr>
    </tbody>
  </table>
</div>

       </div>
    </div>

 <div class="modal fade" id="productOrderModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">

      <div class="modal-header">
        <h5 class="modal-title">Place Product Order</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>

      <div class="modal-body">
        <input type="hidden" id="orderId" value="0" />

        <div class="alert alert-info d-flex align-items-center" role="alert">
          <i class="bi bi-info-circle me-2"></i>
          The price of this order will be reflected from the selected product. If you want to change it, update the product cost instead.
        </div>

        <div class="mb-3">
          <label for="productSelect" class="form-label">Select Product</label>
          <select id="productSelect" class="form-select"></select>
        </div>
          <div class="mb-3">
  <label for="supplierSelect" class="form-label">Supplier</label>
  <select id="supplierSelect" class="form-select"></select>
</div>

        <div class="mb-3">
          <label for="price" class="form-label">Unit Price</label>
          <input type="text" id="price" class="form-control" readonly />
        </div>

        <div class="mb-3">
          <label for="quantity" class="form-label">Quantity</label>
          <input type="number" id="quantity" class="form-control" />
        </div>

        <div class="mb-3">
          <label class="form-label">Order Status</label>
          <div id="statusBadge">
            <span class="badge bg-secondary">Pending</span>
          </div>
        </div>

        <div class="mb-3">
          <label for="notes" class="form-label">Notes</label>
          <textarea id="notes" class="form-control" placeholder="Optional notes"></textarea>
        </div>

      </div>

      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
        <button type="button" class="btn btn-primary" id="saveOrderBtn">Place Order</button>
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
        var order_id = "0"
        $("#placeorder").click(() => {
            order_id = "0"
            resetControls("#productOrderModal")
            $("#productOrderModal").modal("show")
        })
        function loadProductOrders() {
            sendRequest("Api/ProductOrderApi.asmx/GetAllProductOrders", {}, (err, res) => {
                const tbody = document.querySelector("#ordersTable tbody");
                tbody.innerHTML = "";

                if (err || !res.Status || !res.Data.length) {
                    tbody.innerHTML = `<tr><td colspan="9">No Data Available</td></tr>`;
                    return;
                }

                res.Data.forEach(order => {
                    const statusBadge = order.Status === "Completed"
                        ? `<span class="badge bg-success">COMPLETED</span>`
                        : `<span class="badge bg-warning text-dark">PENDING</span>`;

                    const row = `
                <tr>
                    <td>${order.ProductName}</td>
                    <td>${order.SupplierName || "N/A"}</td>
                    <td>${order.Quantity}</td>
                    <td>$${order.UnitPrice}</td>
                    <td>$${order.TotalPrice}</td>
                    <td>${statusBadge}</td>
                    <td>${order.OrderedBy || "-"}</td>
                    <td>${order.OrderDate}</td>
                    <td>
                        <i class="fa fa-edit text-info me-2 cursor-pointer" onclick="editOrder(${order.OrderId})" title="Edit"></i>
                        <i class="fa fa-trash text-danger me-2 cursor-pointer" onclick="deleteItem('productOrders',${order.OrderId},loadProductOrders)" title="Delete"></i>
                        ${order.Status === "Pending"
                            ? `<i class="fa fa-check text-success cursor-pointer" onclick="completeOrder(${order.OrderId})" title="Mark as Completed"></i>`
                            : ""}
                    </td>
                </tr>
            `;
                    tbody.insertAdjacentHTML("beforeend", row);
                });
            });
        }


        // Save order
        document.getElementById("saveOrderBtn").addEventListener("click", () => {
            const ProductId = parseInt(document.getElementById("productSelect").value);
            const Quantity = parseInt(document.getElementById("quantity").value);
            const OrderedBy = "admin"; // dynamically set if needed
            const Notes = document.getElementById("notes").value;
            const SupplierId = parseInt($("#supplierSelect").val());
            if (!ProductId || !Quantity || !SupplierId) {
                showToast("Please select a product and enter quantity and supplier", "error");
                return;
            }

            sendRequest("Api/ProductOrderApi.asmx/SaveOrUpdateProductOrder", {
                OrderId: order_id,
                ProductId,
                Quantity,
                OrderedBy,
                Notes,
                SupplierId
            }, (error, response) => {
                if (error) return showToast("Order save failed", "error");
                const { Status, Message } = response;
                if (Status) {
                    showToast(Message, "success");
                    $('#productOrderModal').modal('hide');
                    loadProductOrders()
                } else {
                    showToast(Message, "error");
                }
            });
        });
        $(document).ready(() => {
            loadSelectOptions("productSelect", {
                tableName: "Products|extra=CostPrice",
                valueColumn: "ProductId",
                textColumn: "ProductName"
            }, (extra) => {
                // Now global: window._dropdownExtras["productSelect"]
                console.log("Structured Extras:", extra);
            });

            loadSelectOptions("supplierSelect", {
                tableName: "Suppliers",
                valueColumn: "SupplierId",
                textColumn: "SupplierName",
                defaultText: "Select Supplier"
            });


            $("#productSelect").on("change", function () {
                const selectedId = this.value;

                const extras = window._dropdownExtras?.["productSelect"] || [];
                const found = extras.find(x => x.itemId === selectedId);

                if (found) {
                    console.log("Selected product price:", found.CostPrice);
                    $("#price").val(`$${found.CostPrice}`);
                }
            });


            loadProductOrders()


        })


        function completeOrder(orderId) {
   
            showConfirmModal({
                message: "Mark this order as completed? Do you want to continue",
                onConfirm: () => {
                    sendRequest("Api/ProductOrderApi.asmx/CompleteProductOrder", { OrderId: orderId }, (err, res) => {
                        if (err || !res.Status) {
                            showToast("Error completing order", "error");
                            return;
                        }
                        showToast(res.Message, "success");
                        loadProductOrders();
                    });
                }
            });

          
        }
        function editOrder(orderId) {
            sendRequest("Api/ProductOrderApi.asmx/GetAllProductOrders", {}, (err, res) => {
                if (err || !res.Status) return;

                const order = res.Data.find(x => x.OrderId == orderId);
                if (!order) return;

                order_id = order.OrderId;
                $("#supplierSelect").val(order.SupplierId).trigger("change");
                $("#productSelect").val(order.ProductId).trigger("change");
                $("#quantity").val(order.Quantity);
                $("#notes").val(order.Notes);

                $("#productOrderModal").modal("show");
            });
        }

    </script>
</asp:Content>