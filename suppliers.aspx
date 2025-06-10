<%@ Page Language="C#" MasterPageFile="~/MasterPage.Master" AutoEventWireup="true" CodeFile="suppliers.aspx.cs" Inherits="suppliers" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">
        <h3 class="text-primary">Suppliers List</h3>
<p>Here you can manage all suppliers.</p>
    </div>

    <div class="card">
        <div class="card-header">
            <button class="btn btn-primary" id="addNewSupplier">Add New Supplier</button>
        </div>
       <div class="card-body p-3">
             <div class="table-responsive text-nowrap">
                  <table class="table" id="supplierTable">
                    <thead>
                      <tr>
                        <th>Supplier</th>
                        <th>Mobile</th>
                        <th>Address</th>
                        <th>Company</th>
                        <th>Actions</th>
                      </tr>
                    </thead>
                    <tbody class="table-border-bottom-0">
                      <tr>
                    <td colspan="5">No Data Avaialble</td>
                      </tr>


                    </tbody>
                  </table>
                </div>
       </div>
    </div>

<div class="modal fade" id="supplierModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Supplier Info</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="supplierId" />

        <div class="mb-3">
          <label for="supplierName" class="form-label required-label">Full Name</label>
          <input type="text" id="supplierName" class="form-control" placeholder="Supplier name" required />
        </div>

        <div class="mb-3">
          <label for="supplierMobile" class="form-label required-label">Phone</label>
          <input type="text" id="supplierMobile" class="form-control" placeholder="Phone number" required />
        </div>

        <div class="mb-3">
          <label for="supplierCompany" class="form-label">Company Name</label>
          <input type="text" id="supplierCompany" class="form-control" placeholder="Company (optional)" />
        </div>

        <div class="mb-3">
          <label for="supplierEmail" class="form-label">Email</label>
          <input type="email" id="supplierEmail" class="form-control" placeholder="example@mail.com" />
        </div>

        <div class="mb-3">
          <label for="supplierAddress" class="form-label">Address</label>
          <textarea id="supplierAddress" class="form-control" rows="3" placeholder="Address (optional)"></textarea>
        </div>
      </div>

      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
        <button type="button" class="btn btn-primary" id="saveSupplierBtn">Save Supplier</button>
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
        var supplierID = "0"
        $("#addNewSupplier").click(() => {
            supplierID = "0"
            resetControls("#supplierModal")
            $("#supplierModal").modal("show")
        })

        function loadSuppliers() {
            sendRequest("Api/register_api.asmx/GetSuppliers", {}, function (err, res) {
                if (err || !res.Status) {
                    $("#supplierTable tbody").html(`<tr><td colspan="5" class="text-center text-danger">Failed to load suppliers</td></tr>`);
                    return;
                }

                const suppliers = res.Data;
                if (!suppliers.length) {
                    $("#supplierTable tbody").html(`<tr><td colspan="5" class="text-center">No Data Available</td></tr>`);
                    return;
                }

                let html = "";
                suppliers.forEach(s => {
                    const encoded = encodeURIComponent(JSON.stringify(s));
                    html += `
        <tr>
          <td>${s.SupplierName}</td>
          <td>${s.Mobile}</td>
          <td>${s.Address || '-'}</td>
          <td>${s.CompanyName || '-'}</td>
          <td>
            <div class="dropdown">
              <button type="button" class="btn p-0 dropdown-toggle hide-arrow" data-bs-toggle="dropdown">
                <i class="bx bx-dots-vertical-rounded"></i>
              </button>
              <div class="dropdown-menu">
                <a class="dropdown-item" href="javascript:void(0);" onclick="editSupplier('${encoded}')">
                  <i class="bx bx-edit-alt me-1"></i> Edit
                </a>
                <a class="dropdown-item" href="javascript:void(0);" onclick="deleteItem('Suppliers', ${s.SupplierID}, loadSuppliers)">
                  <i class="bx bx-trash me-1"></i> Delete
                </a>
              </div>
            </div>
          </td>
        </tr>
      `;
                });

                $("#supplierTable tbody").html(html);
            });
        }

        function editSupplier(encodedData) {
            const data = JSON.parse(decodeURIComponent(encodedData));

           supplierID= data.SupplierID;
            $("#supplierName").val(data.SupplierName);
            $("#supplierMobile").val(data.Mobile);
            $("#supplierEmail").val(data.Email || "");
            $("#supplierAddress").val(data.Address || "");
            $("#supplierCompany").val(data.CompanyName || "");

            $("#supplierModal").modal("show");
        }

        $("#saveSupplierBtn").click(function () {
       
            const supplierName = $("#supplierName").val().trim();
            const mobile = $("#supplierMobile").val().trim();

            if (!supplierName || !mobile) {
                showToast("Name and Mobile are required!", "error");
                return;
            }

            const data = {
                SupplierID: supplierID,
                SupplierName: supplierName,
                Mobile: mobile,
                Email: $("#supplierEmail").val().trim(),
                Address: $("#supplierAddress").val().trim(),
                CompanyName: $("#supplierCompany").val().trim()
            };

            sendRequest("Api/register_api.asmx/SaveSupplier", data, (err, res) => {
                if (err || !res.Status) {
                    showToast(res?.Message || "Error saving supplier", "error");
                    return;
                }

                showToast(res.Message, "success");
                supplierID="0"
                $("#supplierModal").modal("hide");
                loadSuppliers(); // Reload the supplier list
            });
        });

        $(document).ready(() => {
            loadSuppliers();
        })



    </script>
</asp:Content>
