<%@ Page Language="C#" MasterPageFile="~/MasterPage.Master" AutoEventWireup="true" CodeFile="customers.aspx.cs" Inherits="customers" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">
        <h3 class="text-primary">Customers List</h3>
<p>Here you can manage all customers.</p>
    </div>

    <div class="card">
        <div class="card-header">
            <button class="btn btn-primary" id="addNewCustomer">Add New Customer</button>
        </div>
       <div class="card-body p-3">
             <div class="table-responsive text-nowrap">
                  <table class="table" id="customerTable">
                    <thead>
                      <tr>
                        <th>Customer</th>
                        <th>Mobile</th>
                        <th>Email</th>
                        <th>Address</th>
                        <th>Actions</th>
                      </tr>
                    </thead>
                    <tbody class="table-border-bottom-0">
                      <tr>
                    <td colspan="4">No Data Avaialble</td>
                      </tr>


                    </tbody>
                  </table>
                </div>
       </div>
    </div>

<div class="modal fade" id="customerModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Customer Info</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="customerId" />
        <div class="mb-3">
          <label for="customerName" class="form-label required-label">Full Name</label>
          <input type="text" id="customerName" class="form-control" placeholder="Customer name" required />
        </div>
        <div class="mb-3">
          <label for="customerPhone" class="form-label">Phone</label>
          <input type="text" id="customerPhone" class="form-control" placeholder="Phone number" required />
        </div>
        <div class="mb-3">
          <label for="customerEmail" class="form-label">Email</label>
          <input type="email" id="customerEmail" class="form-control" placeholder="example@mail.com" />
        </div>
        <div class="mb-3">
          <label for="customerAddress" class="form-label">Address</label>
          <textarea id="customerAddress" class="form-control" rows="3" placeholder="Address (optional)"></textarea>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
        <button type="button" class="btn btn-primary" id="saveCustomerBtn">Save Customer</button>
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
        var customerId = "0"
        $("#addNewCustomer").click(() => {
            resetControls("#customerModal")
            $("#customerModal").modal("show")
        })
        function loadCustomers() {
            sendRequest("Api/register_api.asmx/GetCustomers", {}, function (err, res) {
                if (err || !res.Status) {
                    showToast(res?.Message || "Error loading customers", "error");
                    return;
                }

                const customers = res.Data;
                if (!customers.length) {
                    $("#customerTable tbody").html('<tr><td colspan="5" class="text-center text-muted">No data available</td></tr>');
                    return;
                }

                let html = "";
                customers.forEach(c => {
                    const encoded = encodeURIComponent(JSON.stringify(c));
                    html += `
            <tr>
                <td>${c.FullName}</td>
                <td>${c.Phone}</td>
                <td>${c.Email || "-"}</td>
                <td>${c.Address || "-"}</td>
                <td>
                    <div class="dropdown">
                        <button class="btn p-0 dropdown-toggle hide-arrow" data-bs-toggle="dropdown">
                            <i class="bx bx-dots-vertical-rounded"></i>
                        </button>
                        <div class="dropdown-menu">
                            <a class="dropdown-item" href="javascript:void(0);" onclick="editCustomer('${encoded}')">
                                <i class="bx bx-edit-alt me-1"></i> Edit
                            </a>
                            <a class="dropdown-item" href="javascript:void(0);" onclick="deleteItem('Customers', ${c.CustomerID},loadCustomers)">
                                <i class="bx bx-trash me-1"></i> Delete
                            </a>
                        </div>
                    </div>
                </td>
            </tr>`;
                });

                $("#customerTable tbody").html(html);
            });
        }

        $("#saveCustomerBtn").click(function () {
     
            const name = $("#customerName").val().trim();
            const phone = $("#customerPhone").val().trim();
            const email = $("#customerEmail").val().trim();
            const address = $("#customerAddress").val().trim();

            if (!name || !phone) {
                alert("Name and phone are required!", "error");
                return;
            }

            const payload = {
                CustomerID: customerId,
                FullName: name,
                Phone: phone,
                Email: email,
                Address: address
            };

            sendRequest("Api/register_api.asmx/SaveCustomer", payload, function (error, response) {
                if (error) {
                    showToast("An error occurred, please try again", "error");
                    return;
                }

                const { Status, Message } = response;
                if (Status) {
                    showToast(Message, "success");
                    $("#customerModal").modal("hide");
                    loadCustomers(); // Optionally reload the table
                    customerId="0"
                } else {
                    showToast(Message, "error");
                }
            });
        });

        function editCustomer(encodedData) {
            const data = JSON.parse(decodeURIComponent(encodedData));
           customerId =data.CustomerID;
            $("#customerName").val(data.FullName);
            $("#customerPhone").val(data.Phone);
            $("#customerEmail").val(data.Email);
            $("#customerAddress").val(data.Address);
            $("#customerModal").modal("show");
        }


        $(document).ready(() => {
            loadCustomers()
        })

    </script>
</asp:Content>

