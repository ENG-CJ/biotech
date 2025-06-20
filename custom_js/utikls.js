function sendRequest(url, data, callback) {
    $.ajax({
        type: "POST",
        url: url,
        data: JSON.stringify(data),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            if (response && response.d) {
                callback(null, response.d);
            } else {
                callback("No response", null);
            }
        },
        error: function (xhr, status, error) {
            console.error("AJAX Error: ", error);
            callback(error, null);
        }
    });
}


function deleteItem(table, id, callback = null) {
    showConfirmModal({
        message: "This Data will be removed from the storage, so do you want to delete this Data?",
        onConfirm: () => {  
            sendRequest("../Api/general.asmx/DeleteItem", {
                table: table,
                id: id
            }, function (err, res) {
                if (err) return alert("Error occurred", "error");

                const { Status, Message } = res;
                if (Status) {
                    showToast(Message, "success");
                    if (callback) callback();
                } else {
                    showToast(Message, "error");
                }
            });
        }
    });

  
}

function loadSelectOptions(selectId, config, onExtra = null) {
    const {
        tableName,
        valueColumn,
        textColumn,
        defaultText = "Select an option"
    } = config;

    const $select = $("#" + selectId);
    $select.html('<option>Loading...</option>');

    sendRequest("../Api/general.asmx/GetDropdownData", {
        tableName,
        valueColumn,
        textColumn,
        defaultText
    }, (err, res) => {
        if (err || !res.Status) {
            $select.html('<option disabled>Error loading options</option>');
            return;
        }

        const data = res.Data;
        let html = "";
        const extraList = [];

        data.forEach(item => {
            html += `<option value="${item.Value}">${item.Text}</option>`;

            if (item.Extra) {
                extraList.push({
                    itemId: item.Value,
                    ...item.Extra
                });
            }
        });

        $select.html(html);

        // ✅ Store globally
        window._dropdownExtras = window._dropdownExtras || {};
        window._dropdownExtras[selectId] = extraList;

        if (typeof onExtra === "function" && extraList.length) {
            onExtra(extraList);
        }
    });
}





function showToast(message, type = "info", duration = 3000, position = "right", gravity = "top") {
    const colors = {
        success: "#28a745",
        error: "#dc3545",
        warning: "#ffc107",
        info: "#17a2b8",
        default: "#6c757d"
    };

    Toastify({
        text: message,
        duration: duration,
        gravity: gravity, // top or bottom
        position: position, // left, center or right
        backgroundColor: colors[type] || colors.default,
        close: true,
        stopOnFocus: true,
        offset: {
            x: 10,
            y: 10
        }
    }).showToast();
}


function resetControls(parentSelector) {
    const parent = document.querySelector(parentSelector);
    if (!parent) return;

    // Reset input, textarea, and select fields
    parent.querySelectorAll("input, textarea, select").forEach(el => {
        switch (el.type) {
            case "checkbox":
            case "radio":
                el.checked = false;
                break;
            case "select-one":
            case "select-multiple":
                el.selectedIndex = 0;
                break;
            default:
                el.value = "";
        }
    });
}

function showConfirmModal({
    title = "Are you sure?",
    message = "Do you want to proceed?",
    icon = "bx bx-help-circle text-warning",
    confirmText = "Yes",
    cancelText = "Cancel",
    confirmClass = "btn btn-danger",
    cancelClass = "btn btn-outline-secondary",
    onConfirm = null,
    onCancel = null
} = {}) {
    // Check if modal already exists
    let modal = document.getElementById("customConfirmModal");
    if (modal) modal.remove();

    const modalHTML = `
    <div class="modal fade" id="customConfirmModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-sm    modal-dialog-centered" role="document">
        <div class="modal-content">
          <div class="modal-header border-bottom-0">
            <h5 class="modal-title"><i class="${icon} me-2"></i>${title}</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <p class="mb-0">${message}</p>
          </div>
          <div class="modal-footer justify-content-end">
            <button type="button" class="${cancelClass}" data-bs-dismiss="modal">${cancelText}</button>
            <button type="button" class="${confirmClass}" id="confirmModalBtn">${confirmText}</button>
          </div>
        </div>
      </div>
    </div>
  `;

    document.body.insertAdjacentHTML("beforeend", modalHTML);

    const confirmModal = new bootstrap.Modal(document.getElementById("customConfirmModal"));
    confirmModal.show();

    document.getElementById("confirmModalBtn").addEventListener("click", () => {
        confirmModal.hide();
        if (typeof onConfirm === "function") onConfirm();
    });

    document.getElementById("customConfirmModal").addEventListener("hidden.bs.modal", () => {
        if (typeof onCancel === "function") onCancel();
        document.getElementById("customConfirmModal").remove();
    });
}


