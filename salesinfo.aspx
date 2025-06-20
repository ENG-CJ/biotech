<%@ Page Language="C#" MasterPageFile="~/MasterPage.Master" AutoEventWireup="true" CodeFile="salesinfo.aspx.cs" Inherits="salesinfo" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <h3 class="text-primary">Sales info</h3>
    <p>View and manage all sales transactions.</p>

    <div class="card">
        <div class="card-header">
            <button class="btn btn-primary" id="newsale">New sale</button>
        </div>
       <div class="card-body p-3">
       <div class="table-responsive text-nowrap">
<table class="table" id="salesInfoTable">
  <thead>
    <tr>
      <th>Invoice</th>
      <th>Customer</th>
      <th>Total</th>
      <th>Paid</th>
      <th>Payment</th>
      <th>Date</th>
      <th>Actions</th>
    </tr>
  </thead>
  <tbody class="table-border-bottom-0">
    <tr><td colspan="8">No Data Available</td></tr>
  </tbody>
</table>

</div>

       </div>
    </div>


    <div class="modal fade" id="saleDetailModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-scrollable">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="saleDetailModalTitle">Sale Details</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <table class="table table-sm table-bordered mb-0">
          <thead>
            <tr>
              <th>Product</th>
              <th>Qty</th>
              <th>Price</th>
              <th>Total</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody id="saleDetailBody">
            <tr><td colspan="5">Loading...</td></tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>


    <div class="modal fade" id="returnModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-scrollable">
    <div class="modal-content">

      <div class="modal-header">
        <h5 class="modal-title">
          <i class="fa fa-undo me-1"></i> Return Sale – <span id="returnSaleTitle"></span>
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>

      <div class="modal-body">
        <div id="returnNote" class="alert alert-info">
          Select the product(s) you want to return from this sale. You can partially return quantities.
        </div>

        <table class="table table-sm table-bordered">
          <thead>
            <tr>
              <th><input type="checkbox" id="selectAllReturnItems" /></th>
              <th>Product</th>
              <th>Qty Sold</th>
              <th>Return Qty</th>
              <th>Unit Price</th>
              <th>Total</th>
            </tr>
          </thead>
          <tbody id="returnItemsContainer"></tbody>
        </table>
      </div>

      <div class="modal-footer">
        <div class="me-auto">
          <strong>Total Refund: $<span id="returnTotalAmount">0.00</span></strong>
        </div>
        <button type="button" class="btn btn-primary" onclick="submitSaleReturn()">
          <i class="fa fa-check me-1"></i> Confirm Return
        </button>
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
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

        $("#newsale").click(() => window.location.href="sales.aspx")

        let currentReturnSaleId = 0;
        let returnSaleItems = [];

        function openReturnModal(saleId) {
            currentReturnSaleId = saleId;
            returnSaleItems = [];
            $("#returnItemsContainer").html(`<tr><td colspan="6">Loading...</td></tr>`);
            $("#returnSaleTitle").text(`#INV-${String(saleId).padStart(6, '0')}`);
            $("#returnTotalAmount").text("0.00");

            sendRequest("Api/Sales_api.asmx/GetSaleDetails", { SaleId: saleId }, (err, res) => {
                if (err || !res.Status) {
                    $("#returnItemsContainer").html(`<tr><td colspan="6">Failed to load items</td></tr>`);
                    return;
                }

                const items = res.Data;
                if (!items.length) {
                    $("#returnItemsContainer").html(`<tr><td colspan="6">No items found</td></tr>`);
                    return;
                }

                let html = "";
                items.forEach((item, index) => {
                    html += `
        <tr>
          <td>
            <input type="checkbox" class="return-check" data-idx="${index}" onchange="toggleReturnSelection(${index})" />
          </td>
          <td>${item.ProductName}</td>
          <td>${item.Quantity}</td>
          <td>
            <input type="number" class="form-control form-control-sm return-qty-input" data-idx="${index}" 
              value="${item.Quantity}" min="1" max="${item.Quantity}" onchange="recalcReturnAmount()" disabled />
          </td>
          <td>$${parseFloat(item.UnitPrice).toFixed(2)}</td>
          <td>
            $<span class="return-item-total" data-idx="${index}">${(item.Quantity * item.UnitPrice).toFixed(2)}</span>
          </td>
        </tr>
      `;

                    returnSaleItems.push({
                        ProductId: item.ProductId,
                        ProductName: item.ProductName,
                        Quantity: item.Quantity,
                        UnitPrice: item.UnitPrice,
                        ReturnQty: 0
                    });
                });

                $("#returnItemsContainer").html(html);
                new bootstrap.Modal(document.getElementById("returnModal")).show();
            });
        }
        function toggleReturnSelection(index) {
            const checkbox = document.querySelector(`.return-check[data-idx="${index}"]`);
            const qtyInput = document.querySelector(`.return-qty-input[data-idx="${index}"]`);
            const selected = checkbox.checked;

            if (selected) {
                qtyInput.disabled = false;
                returnSaleItems[index].ReturnQty = parseInt(qtyInput.value) || 0;
            } else {
                qtyInput.disabled = true;
                returnSaleItems[index].ReturnQty = 0;
            }

            recalcReturnAmount();
        }

        function recalcReturnAmount() {
            let total = 0;
            returnSaleItems.forEach((item, index) => {
                const input = document.querySelector(`.return-qty-input[data-idx="${index}"]`);
                const qty = parseInt(input?.value || 0);
                const totalEl = document.querySelector(`.return-item-total[data-idx="${index}"]`);

                if (!input.disabled && qty > 0 && qty <= item.Quantity) {
                    item.ReturnQty = qty;
                    const itemTotal = qty * item.UnitPrice;
                    total += itemTotal;
                    totalEl.textContent = itemTotal.toFixed(2);
                } else {
                    item.ReturnQty = 0;
                    totalEl.textContent = "0.00";
                }
            });

            $("#returnTotalAmount").text(total.toFixed(2));
        }

        $("#selectAllReturnItems").on("change", function () {
            const isChecked = this.checked;
            document.querySelectorAll(".return-check").forEach(cb => {
                cb.checked = isChecked;
                cb.dispatchEvent(new Event('change'));
            });
        });

        function submitSaleReturn() {
            const selectedItems = returnSaleItems.filter(i => i.ReturnQty > 0);
            if (!selectedItems.length) {
                showToast("No items selected for return", "error");
                return;
            }

            const totalRefund = selectedItems.reduce((sum, i) => sum + (i.ReturnQty * i.UnitPrice), 0);

            sendRequest("Api/Sales_api.asmx/ProcessSaleReturn", {
                SaleId: currentReturnSaleId,
                ReturnedBy: "admin",
                Notes: "Returned by user",
                TotalRefund: totalRefund,
                Items: selectedItems.map(i => ({
                    ProductId: i.ProductId,
                    Quantity: i.ReturnQty,
                    UnitPrice: i.UnitPrice
                }))
            }, (err, res) => {
                if (err || !res.Status) {
                    showToast("Failed to return sale", "error");
                    return;
                }

                showToast("Sale return successful", "success");
                $(".modal").modal("hide");
                loadSalesTable(); // reload updated data
            });
        }


        $(document).ready(() => {
            loadSalesTable()
        })
        function loadSalesTable() {
            const tbody = $("#salesInfoTable tbody");
            tbody.html(`<tr><td colspan="9">Loading...</td></tr>`);

            sendRequest("Api/Sales_api.asmx/GetAllSales", {}, (err, res) => {
                if (err || !res.Status) {
                    tbody.html(`<tr><td colspan="9">Failed to load sales</td></tr>`);
                    return;
                }

                const sales = res.Data;
                if (!sales.length) {
                    tbody.html(`<tr><td colspan="9">No data available</td></tr>`);
                    return;
                }

                let html = "";
                sales.forEach(sale => {
                    const badge = sale.PaymentType === "Credit"
                        ? `<span class="badge bg-danger">Credit</span>`
                        : `<span class="badge bg-success">${sale.PaymentType}</span>`;

                    const encoded = encodeURIComponent(JSON.stringify(sale));

                    html += `
                <tr>
                    <td>INV-${String(sale.SaleId).padStart(6, "0")}</td>
                    <td>${sale.CustomerName}</td>
                    <td>$${parseFloat(sale.TotalAmount).toFixed(2)}</td>
                    <td>$${parseFloat(sale.PaidAmount).toFixed(2)}</td>
                    <td>${badge}</td>
               
                    <td>${sale.SaleDate}</td>
                    <td>
                        <div class="dropdown">
                            <button class="btn p-0 dropdown-toggle hide-arrow" type="button" data-bs-toggle="dropdown">
                                <i class="bx bx-dots-vertical-rounded"></i>
                            </button>
                            <ul class="dropdown-menu">
                                <li>
                                    <a class="dropdown-item" href="javascript:void(0);" onclick="cancelSale(${sale.SaleId})">
                                        <i class="bx bx-block me-1"></i> Cancel Sale
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item" href="javascript:void(0);" onclick="openReturnModal(${sale.SaleId})">
                                        <i class="bx bx-undo me-1"></i> Return Sale
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item" href="javascript:void(0);" onclick="viewSaleDetail(${sale.SaleId})">
                                        <i class="bx bx-detail me-1"></i> View Details
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item" href="javascript:void(0);" onclick="printPOSInvoiceFromDB(${sale.SaleId})">
                                        <i class="bx bx-printer me-1"></i> Print Invoice
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

        function returnSale(saleId) {
            showToast("Return process for sale ID " + saleId + " initiated", "info");
            // to be implemented...
        }

        function viewSaleDetail(saleId) {
            $("#saleDetailModalTitle").text(`#INV-${String(saleId).padStart(6, "0")} Sale Details`);
            $("#saleDetailBody").html(`<tr><td colspan="5">Loading...</td></tr>`);

            sendRequest("Api/Sales_api.asmx/GetSaleDetails", { SaleId: saleId }, (err, res) => {
                if (err || !res.Status) {
                    $("#saleDetailBody").html(`<tr><td colspan="5">Failed to load data</td></tr>`);
                    return;
                }

                const data = res.Data;
                if (!data.length) {
                    $("#saleDetailBody").html(`<tr><td colspan="5">No items found</td></tr>`);
                    return;
                }

                let html = "";
                data.forEach(item => {
                    html += `
                <tr>
                    <td>${item.ProductName}</td>
                    <td>${item.Quantity}</td>
                    <td>$${parseFloat(item.UnitPrice).toFixed(2)}</td>
                    <td>$${parseFloat(item.TotalPrice).toFixed(2)}</td>
                    <td>
                        <button class="btn btn-sm btn-outline-danger" title="Remove item and return stock"
                            onclick="removeSaleItem(${item.SaleDetailId}, ${item.ProductId}, ${item.Quantity})">
                            <i class="fa fa-times"></i>
                        </button>
                    </td>
                </tr>`;
                });

                $("#saleDetailBody").html(html);
                new bootstrap.Modal(document.getElementById("saleDetailModal")).show();
            });
        }



        function removeSaleItem(saleDetailId, productId, quantity) {

            showConfirmModal({
                message: "You are canceling Product #" + productId + " From the invoice detail id #" + saleDetailId +"We'll remove it from this invoice and we will revert all quantity for this product back to the inventory, Do you want to continue?",
                onConfirm: () => {
                    sendRequest("Api/Sales_api.asmx/RemoveSaleItem", {
                        SaleDetailId: saleDetailId,
                        ProductId: productId,
                        Quantity: quantity
                    }, (err, res) => {
                        if (err || !res.Status) {
                            showToast("Failed to remove item", "error");
                            return;
                        }

                        showToast("Item removed and stock restored", "success");
                        $(".modal").modal("hide");
                        setTimeout(() => viewSaleDetail(parseInt($("#saleDetailModalTitle").text().replace(/\D/g, ''))), 500);
                    });
                }
            });


        
        }



        function cancelSale(saleId) {
            showConfirmModal({
                message: "You are canceling sale invoice of #" + saleId+" We'll remove all daat from this invoice and we will revert all quantity for this sale back to the inventory, Do you want to continue?",
                onConfirm: () => {
                    sendRequest("Api/Sales_api.asmx/CancelSale", { SaleId: saleId }, (err, res) => {
                        if (err || !res.Status) {
                            showToast("Failed to cancel sale", "error");
                            return;
                        }

                        showToast("Sale cancelled", "success");
                        loadSalesTable(); // Refresh list
                    });
                }
            });

           
        }
        function printPOSInvoiceFromDB(saleId) {
            sendRequest("Api/Sales_api.asmx/GetSaleInvoiceData", { SaleId: saleId }, (err, res) => {
                if (err || !res.Status) {
                    showToast("Failed to load invoice", "error");
                    return;
                }

                const { Info, Items } = res.Data;
                let totalAmount = 0;
                let rows = "";

                Items.forEach(p => {
                    const itemTotal = parseFloat(p.Total);
                    totalAmount += itemTotal;

                    rows += `
                <tr>
                    <td>${p.ProductName}</td>
                    <td style="text-align:right;">${p.Quantity}</td>
                    <td style="text-align:right;">${parseFloat(p.UnitPrice).toFixed(2)}</td>
                    <td style="text-align:right;">${itemTotal.toFixed(2)}</td>
                </tr>`;
                });

                const due = totalAmount - parseFloat(Info.PaidAmount);

                const html = `
        <div style="width:300px;padding:10px;font-family:monospace;font-size:13px;">
            <div style="text-align:center;">
                <img src="assets/img/logo-placeholder.png" width="50" />
                <h4 style="margin:5px 0;">BIO-TECH MEDICAL</h4>
                <p style="margin:0;">Hargeisa - Somaliland</p>
                <p style="margin:0;">Tel: +252 63 9999999</p>
                <hr />
            </div>

            <div style="margin: 5px 0;">
                <div>Date: ${Info.SaleDate}</div>
                <div>Customer: ${Info.CustomerName}</div>
                <div>Payment: ${Info.PaymentType}</div>
            </div>

            <hr />

            <table style="width:100%;border-collapse:collapse;margin-top:5px;">
                <thead>
                    <tr>
                        <th style="text-align:left;">Item</th>
                        <th style="text-align:right;">Qty</th>
                        <th style="text-align:right;">Price</th>
                        <th style="text-align:right;">Total</th>
                    </tr>
                </thead>
                <tbody>${rows}</tbody>
            </table>

            <hr />

            <div style="text-align:right;">
                <div>Total: $${totalAmount.toFixed(2)}</div>
                <div>Paid: $${parseFloat(Info.PaidAmount).toFixed(2)}</div>
                <div>Due: $${due.toFixed(2)}</div>
            </div>

            <div style="text-align:center;margin-top:10px;">
                <p>Thanks for your purchase!</p>
                <p style="font-size:11px;">Powered by Hadaf ICT</p>
            </div>
        </div>`;

                const printWindow = window.open('', '', 'width=400,height=600');
                printWindow.document.write(`<html><head><title>POS Invoice</title></head><body onload="window.print();window.close();">${html}</body></html>`);
                printWindow.document.close();
            });
        }


    </script>
</asp:Content>
