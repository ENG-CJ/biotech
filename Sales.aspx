<%@ Page Language="C#" MasterPageFile="~/MasterPage.Master" AutoEventWireup="true" CodeFile="Sales.aspx.cs" Inherits="Sales" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h3 class="text-primary">
            <i class="fa fa-cash-register me-2"></i> Let Sale a Product
        </h3>
        <div>
            <button type="button" class="btn btn-outline-dark position-relative" onclick="viewCart()">
                <i class="fa fa-shopping-cart"></i> View Cart
                <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger" id="cartCount">
                    0
                </span>
            </button>
        </div>
    </div>
      <div class="row" id="salesProductContainer">
        <!-- Product cards will be rendered here -->
    </div>

   <div class="modal fade" id="cartModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-scrollable" role="document">
    <div class="modal-content">
      
      <div class="modal-header">
        <h5 class="modal-title">
          <i class="fa fa-shopping-cart me-2"></i> Cart Items
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>

      <div class="modal-body" id="cartItemsContainer">
        <!-- dynamic cart content -->
      </div>

      <div class="modal-footer d-flex justify-content-between">
        <%--<h5 class="text-primary m-0">
          <i class="fa fa-coins me-1"></i> Total: 
          <strong id="cartOverallTotal">$0.00</strong>
        </h5>--%>
        <div>
          <button class="btn btn-danger me-2" onclick="clearCart()">
            <i class="fa fa-trash me-1"></i> Clear Cart
          </button>
            <button class="btn btn-success" onclick="openCheckout()">
  <i class="fa fa-credit-card me-1"></i> Checkout
</button>

          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
        </div>
      </div>

    </div>
  </div>
</div>

    <div class="modal fade" id="checkoutModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
    <div class="modal-content">
      
      <div class="modal-header">
        <h5 class="modal-title">
          <i class="fa fa-credit-card me-2"></i> Finalize Checkout
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>

      <div class="modal-body">
          <div class="mb-3">
  <label for="customerSelect" class="form-label">
    <i class="fa fa-user me-1"></i> Select Customer
  </label>
  <select id="customerSelect" class="form-select"></select>
</div>


        <div class="mb-3">
          <label for="paymentType" class="form-label">
            <i class="fa fa-money-bill-wave me-1"></i> Payment Type
          </label>
          <select id="paymentType" class="form-select" onchange="handlePaymentTypeChange()">
            <option value="Cash">Cash</option>
            <option value="Bank">Bank</option>
            <option value="Credit">Credit</option>
          </select>
        </div>

        <div id="creditInfo" class="alert alert-info d-none">
          Customer will be monitored under <strong>Due Payment (Credit)</strong>. No payment required at this time.
        </div>

        <div class="mb-3">
          <label for="paidAmount" class="form-label">
            <i class="fa fa-coins me-1"></i> Paid Amount
          </label>
          <input type="number" id="paidAmount" class="form-control" placeholder="Enter paid amount" min="0" />
        </div>

        <div class="mb-3">
          <label class="form-label">
            <i class="fa fa-money-check-alt me-1"></i> Total Due
          </label>
          <input type="text" id="checkoutTotal" class="form-control bg-light" disabled />
        </div>

      </div>

      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button class="btn btn-primary" onclick="confirmCheckout()">
          <i class="fa fa-check-circle me-1"></i> Confirm Sale
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
    function printPOSFromCart() {
        const cart = getCart();
        if (!cart.length) {
            showToast("Cart is empty", "error");
            return;
        }

        const customerName = $("#customerSelect option:selected").text() || "Walk-in Customer";
        const paymentType = $("#paymentType").val();
        const paidAmount = parseFloat($("#paidAmount").val()) || 0;
        const now = new Date();

        let totalAmount = 0;
        let rows = "";

        cart.forEach(p => {
            const itemTotal = p.Price * p.Quantity;
            totalAmount += itemTotal;
            rows += `
            <tr>
                <td>${p.ProductName}</td>
                <td style="text-align:right;">${p.Quantity}</td>
                <td style="text-align:right;">${p.Price.toFixed(2)}</td>
                <td style="text-align:right;">${itemTotal.toFixed(2)}</td>
            </tr>
        `;
        });

        const due = totalAmount - paidAmount;

        const invoiceHTML = `
    <div style="width:300px;padding:10px;font-family:monospace;font-size:13px;">
        <div style="text-align:center;">
            <img src="assets/img/logo-placeholder.png" width="50" />
            <h4 style="margin:5px 0;">BIO-TECH MEDICAL</h4>
            <p style="margin:0;">Hargeisa - Somaliland</p>
            <p style="margin:0;">Tel: +252 63 9999999</p>
            <hr />
        </div>

        <div style="margin: 5px 0;">
            <div>Date: ${now.toLocaleString()}</div>
            <div>Customer: ${customerName}</div>
            <div>Payment: ${paymentType}</div>
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
            <div>Paid: $${paidAmount.toFixed(2)}</div>
            <div>Due: $${due.toFixed(2)}</div>
        </div>

        <div style="text-align:center;margin-top:10px;">
            <p>Thanks for your purchase!</p>
            <p style="font-size:11px;">Powered by Hadaf ICT</p>
        </div>
    </div>
    `;

        const printWindow = window.open('', '', 'width=400,height=600');
        printWindow.document.write(`<html><head><title>POS Invoice</title></head><body onload="window.print();window.close();">${invoiceHTML}</body></html>`);
        printWindow.document.close();
    }

    function openCheckout() {
        const cart = getCart();
        if (!cart.length) {
            showToast("Cart is empty", "error");
            return;
        }

        // Calculate total
        const total = cart.reduce((sum, item) => sum + item.Price * item.Quantity, 0);

        $("#checkoutTotal").val(`$${total.toFixed(2)}`);
        $("#paidAmount").val("");
        $("#paymentType").val("Cash");
        $("#creditInfo").addClass("d-none");


        loadSelectOptions("customerSelect", {
            tableName: "Customers",
            valueColumn: "CustomerID",
            textColumn: "FullName",
            defaultText: "Walk-in Customer"
        });


        // Close cart modal
        bootstrap.Modal.getInstance(document.getElementById("cartModal")).hide();

        // Show checkout modal
        const checkoutModal = new bootstrap.Modal(document.getElementById("checkoutModal"));
        checkoutModal.show();
    }


    function handlePaymentTypeChange() {
        const type = $("#paymentType").val();
        const paidInput = $("#paidAmount");
        const info = $("#creditInfo");

        if (type === "Credit") {
            info.removeClass("d-none");
            paidInput.val("0").prop("disabled", true);
        } else {
            info.addClass("d-none");
            paidInput.prop("disabled", false).val("");
        }
    }
    function confirmCheckout() {
        const type = $("#paymentType").val();
        const paid = parseFloat($("#paidAmount").val() || 0);
        const total = parseFloat($("#checkoutTotal").val().replace('$', ''));

        if (type !== "Credit") {
            if (isNaN(paid) || paid <= 0) {
                showToast("Enter valid paid amount", "error");
                return;
            }

            if (paid > total) {
                showToast("Paid amount exceeds total", "error");
                return;
            }
        }

        finalizeCheckout()
        //localStorage.removeItem("sales_cart");
        updateCartCount();
    }
    function finalizeCheckout() {
        const cart = getCart();
        if (!cart.length) {
            showToast("Cart is empty", "error");
            return;
        }

        const paymentType = $("#paymentType").val();
        const paidAmount = parseFloat($("#paidAmount").val()) || 0;
        const customerId = parseInt($("#customerSelect").val() || "0"); // 0 for walk-in

        sendRequest("Api/Sales_api.asmx/RegisterSale", {
            CustomerId: customerId,
            PaymentType: paymentType,
            PaidAmount: paidAmount,
            saleDetails: cart
        }, (err, res) => {
            if (err || !res.Status) {
                showToast("Sale failed", "error");
                return;
            }

            showToast("Sale completed successfully", "success");
            printPOSFromCart();
            clearCart();
            loadSaleProducts()
            bootstrap.Modal.getInstance(document.getElementById("checkoutModal")).hide();
        });
    }

    function loadSaleProducts() {
        sendRequest("Api/Sales_api.asmx/GetSaleProducts", {}, (err, res) => {
            if (err || !res.Status) {
                $("#salesProductContainer").html(`<div class="alert alert-danger">Unable to load products</div>`);
                return;
            }

            const products = res.Data;
            const container = $("#salesProductContainer");
            container.html("");

            let html = "";

            products.forEach((p, i) => {
                if (i % 4 === 0) html += `<div class="row mb-4">`;

                html += `
            <div class="col-md-3">
                <div class="card shadow-sm h-100">
                    <div class="card-body text-center">
                        <div class="mb-2">
                            <i class="fa-solid fa-box-open fa-3x text-primary"></i>
                        </div>
                        <h5 class="card-title text-primary">
                            <i class="fa fa-tag me-1"></i> ${p.ProductName}
                        </h5>
                        <p class="card-text">
                            <i class="fa fa-layer-group me-1 text-secondary"></i> Qty: <strong>${p.StockQuantity}</strong><br>
                            <i class="fa fa-dollar-sign me-1 text-success"></i> Price: <strong>$${p.Price}</strong><br>
                            <span class="badge ${p.StockStatus === "In-stock" ? "bg-success" : "bg-danger"}">
                                <i class="fa fa-warehouse me-1"></i> ${p.StockStatus}
                            </span>
                        </p>
                        <button class="btn btn-outline-primary mt-2 add-to-cart"  data-product='${JSON.stringify(p)}'">
                            <i class="fa fa-cart-plus me-1"></i> Add to Cart
                        </button>
                    </div>
                </div>
            </div>
            `;

                if ((i + 1) % 4 === 0 || i === products.length - 1) html += `</div>`;
            });

            container.html(html);
            $(".add-to-cart").on("click", function () {
                const data = $(this).data("product");
                addToCart(data);
            });

          
        });
    }

    function addToCart(product) {
        let cart = getCart();

        const existing = cart.find(item => item.ProductId === product.ProductId);
        if (existing) {
            if (existing.Quantity + 1> product.StockQuantity) {
                showToast("Cannot add more. Product is out of stock!", "error");
                return;
            }

            existing.Quantity += 1;
        } else {
            if (product.StockQuantity < 1) {
                showToast("This product is out of stock!", "error");
                return;
            }
            cart.push({
                ProductId: product.ProductId,
                ProductName: product.ProductName,
                Price: product.Price,
                StockQuantity: product.StockQuantity,
                Quantity: 1
            });
        }

        saveCart(cart);
        updateCartCount();
        showToast("Product added to cart!", "success");
    }

    function getCart() {
        return JSON.parse(localStorage.getItem("sales_cart") || "[]");
    }

    function saveCart(cart) {
        localStorage.setItem("sales_cart", JSON.stringify(cart));
    }

    function updateCartCount() {
        const cart = getCart();
        const totalItems = cart.reduce((sum, item) => sum + item.Quantity, 0);
        $("#cartCount").text(totalItems);
    }


    // Load on page ready
    $(document).ready(() => {
        loadSaleProducts();
        updateCartCount();
    });
    function viewCart() {
        const cart = getCart();
        const container = $("#cartItemsContainer");
        container.html("");

        if (!cart.length) {
            container.html(`<div class="alert alert-info">No items in cart.</div>`);
        }

        let overallTotal = 0;

        cart.forEach(item => {
            const total = item.Price * item.Quantity;
            overallTotal += total;

            container.append(`
            <div class="card mb-3 shadow-sm">
                <div class="card-body d-flex justify-content-between align-items-center">
                    <div>
                        <h5 class="mb-1">
                            <i class="fa fa-tag me-1 text-primary"></i> ${item.ProductName}
                        </h5>
                        <div>
                            <span class="text-muted">
                                <i class="fa fa-dollar-sign me-1"></i> $${item.Price.toFixed(2)} per unit
                            </span>
                            <span class="mx-2">|</span>
                            <span>
                                <i class="fa fa-boxes me-1"></i> Qty: 
                                <button class="btn btn-sm btn-light px-2 py-0" onclick="updateItemQty(${item.ProductId}, -1)">
                                    <i class="fa fa-minus"></i>
                                </button>
                                <strong class="mx-2">${item.Quantity}</strong>
                                <button class="btn btn-sm btn-light px-2 py-0" onclick="updateItemQty(${item.ProductId}, 1)">
                                    <i class="fa fa-plus"></i>
                                </button>
                            </span>
                            <span class="mx-2">|</span>
                            <span class="text-success fw-bold">
                                <i class="fa fa-equals me-1"></i> $${total.toFixed(2)}
                            </span>
                        </div>
                    </div>
                    <div>
                        <button class="btn btn-sm btn-outline-danger" onclick="removeItem(${item.ProductId})">
                            <i class="fa fa-trash"></i>
                        </button>
                    </div>
                </div>
            </div>
        `);
        });

        // Append total row at end
        if (cart.length) {
            container.append(`
            <div class="text-end pe-2 mt-3">
                <h5 class="text-primary">
                    <i class="fa fa-coins me-1"></i> Total: <strong>$${overallTotal.toFixed(2)}</strong>
                </h5>
            </div>
        `);
        }

        const cartModal = new bootstrap.Modal(document.getElementById("cartModal"));
        cartModal.show();
    }


    function updateItemQty(productId, delta) {
        let cart = getCart();
        const item = cart.find(p => p.ProductId === productId);
        if (!item) return;

        const newQty = item.Quantity + delta;

        if (newQty > item.StockQuantity) {
            showToast("Quantity exceeds stock!", "error");
            return;
        }

        if (newQty <= 0) {
            cart = cart.filter(p => p.ProductId !== productId);
        } else {
            item.Quantity = newQty;
        }

        saveCart(cart);
        updateCartCount();
        viewCart(); // reload modal content
    }

    function removeItem(productId) {
        let cart = getCart();
        cart = cart.filter(p => p.ProductId !== productId);
        saveCart(cart);
        updateCartCount();
        viewCart();
    }

    function clearCart() {
        localStorage.removeItem("sales_cart");
        updateCartCount();
    }


</script>

</asp:Content>