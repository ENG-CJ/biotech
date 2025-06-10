<%@ Page Language="C#" MasterPageFile="~/MasterPage.Master" AutoEventWireup="true" CodeFile="logs.aspx.cs" Inherits="logs" %>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .avatar-xl {
    height: auto !important;
    width: auto !important;
}

.log-card {
    border: 1px solid #dee2e6;
    border-radius: 20px;
    padding: 20px;
    margin-bottom: 20px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
    background-color: #fff;
    height: auto;             /* Ensure height grows with content */
    overflow: visible;        /* Allow full content to show */
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}

</style>
    


    <div class="container mt-4">
            <h3 class="text-primary">Logs activity</h3>
    <p>View and report system logs activity.</p>
        <label><strong>Results Found: </strong><kbd id="resulst">0</kbd></label>
    <div class="row" id="logContainer">
        <!-- Dynamic logs will go here -->
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
    $(document).ready(function () {
        loadLogs();
    });

    function loadLogs() {
        sendRequest("Api/logs_api.asmx/GetLogs", {}, function (err, res) {
            if (err || !res.Status) {
                $("#logContainer").html('<div class="text-danger text-center">Failed to load logs.</div>');
                return;
            }

            const logs = res.Data;
            $("#resulst").text(logs.length)
            if (!logs.length) {
                $("#logContainer").html('<div class="text-muted text-center">No logs available.</div>');
                return;
            }

            let html = "";
            logs.forEach(log => {
                const statusIcon = log.IsSuccess
                    ? '<i class="bx bx-check-circle text-success"></i>'
                    : '<i class="bx bx-x-circle text-danger"></i>';
                html += `
                    <div class="col-md-6">
                        <div class="log-card">
                            <div class="d-flex">
                                <div class="flex-shrink-0 me-3">
                                    <div class="avatar avatar-xl">
                                        <img src="assets/profile.png" alt="User" class="rounded-circle" style="width: 64px; height: 64px;">
                                        <div class="mt-2 text-center">${statusIcon} <small class="d-block">Status: ${log.IsSuccess ? 'Success' : 'Failed'}</small></div>
                                    </div>
                                </div>
                                <div class="flex-grow-1">
                                    <div><strong>ACTION TYPE:</strong> ${log.Action}</div>
                                    <div><strong>RECORDED ON:</strong> ${log.CreatedAt}</div>
                                    <div><strong>Role:</strong> ${log.RoleName || 'N/A'} &nbsp;&nbsp; <strong>User:</strong> ${log.Username || 'Guest'}</div>
                                    <div class="mt-2">${log.Details}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                `;
            });

            $("#logContainer").html(html);
        });
    }
</script>
</asp:Content>

