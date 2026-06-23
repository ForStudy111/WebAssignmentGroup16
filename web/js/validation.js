/*
 * Shared client-side validation for the Counseling Management System.
 *
 * Use it on forms with:
 *   class="validate-form"
 *   novalidate
 *
 * Malaysian mobile number format accepted:
 *   012-3456789  (3 digits - 7 digits)
 *   011-12345678 (3 digits - 8 digits)
 */
(function () {
    "use strict";

    function getContainer(field) {
        return field.closest(".form-group") || field.parentElement;
    }

    function clearError(field) {
        field.classList.remove("input-error");

        const oldError = getContainer(field).querySelector(".field-error");

        if (oldError) {
            oldError.remove();
        }
    }

    function showError(field, message) {
        clearError(field);

        field.classList.add("input-error");

        const error = document.createElement("small");
        error.className = "field-error";
        error.textContent = message;

        getContainer(field).appendChild(error);
    }

    function getLabel(field) {
        return field.getAttribute("data-label")
                || field.name
                || "This field";
    }

    function validateField(field) {
        if (field.disabled
                || field.readOnly
                || field.type === "hidden"
                || field.type === "submit"
                || field.type === "button") {
            return true;
        }

        const value = (field.value || "").trim();
        const label = getLabel(field);

        if (field.required && value === "") {
            showError(field, label + " is required.");
            return false;
        }

        if (field.name === "username"
                && value !== ""
                && !/^[A-Za-z0-9_]{3,20}$/.test(value)) {
            showError(field,
                    "Username must contain 3 to 20 letters, numbers, or underscores.");
            return false;
        }

        if (field.name === "fullName"
                && value !== ""
                && value.length < 3) {
            showError(field,
                    "Full name must contain at least 3 characters.");
            return false;
        }

        if ((field.type === "email" || field.name === "email")
                && value !== ""
                && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
            showError(field, "Please enter a valid email address.");
            return false;
        }

        if (field.getAttribute("data-validation") === "phone"
                && value !== ""
                && !/^01[0-9]-\d{7,8}$/.test(value)) {
            showError(field,
                    "Use Malaysian mobile format: 012-3456789 or 011-12345678.");
            return false;
        }

        if (field.getAttribute("data-password") === "true"
                && value !== ""
                && !/^(?=.*[A-Za-z])(?=.*\d)\S{6,}$/.test(value)) {
            showError(field,
                    "Password must have at least 6 characters, including a letter and a number.");
            return false;
        }

        if (field.getAttribute("data-future-date") === "true"
                && value !== "") {
            const selectedDate = new Date(value + "T00:00:00");
            const today = new Date();

            today.setHours(0, 0, 0, 0);

            if (selectedDate < today) {
                showError(field, "Please choose today or a future date.");
                return false;
            }
        }

        const minimumLength = Number(field.getAttribute("data-minlength"));

        if (minimumLength > 0
                && value !== ""
                && value.length < minimumLength) {
            showError(field,
                    label + " must contain at least "
                    + minimumLength + " characters.");
            return false;
        }

        if (field.getAttribute("data-rating") === "true"
                && value !== ""
                && (Number(value) < 1 || Number(value) > 5)) {
            showError(field, "Choose a rating from 1 to 5.");
            return false;
        }

        clearError(field);
        return true;
    }

    function validatePasswordMatch(form) {
        const confirmField = form.querySelector("[data-match]");

        if (!confirmField) {
            return true;
        }

        const passwordField = form.querySelector(
                '[name="' + confirmField.getAttribute("data-match") + '"]'
                );

        if (passwordField
                && passwordField.value !== confirmField.value) {
            showError(confirmField, "Passwords do not match.");
            return false;
        }

        clearError(confirmField);
        return true;
    }

    function validateForm(form) {
        let isValid = true;

        form.querySelectorAll("input, select, textarea").forEach(function (field) {
            if (!validateField(field)) {
                isValid = false;
            }
        });

        if (!validatePasswordMatch(form)) {
            isValid = false;
        }

        return isValid;
    }

    document.addEventListener("DOMContentLoaded", function () {
        document.querySelectorAll("form.validate-form").forEach(function (form) {
            form.addEventListener("submit", function (event) {
                if (!validateForm(form)) {
                    event.preventDefault();
                }
            });

            form.querySelectorAll("input, select, textarea").forEach(function (field) {
                field.addEventListener("input", function () {
                    validateField(field);
                });

                field.addEventListener("change", function () {
                    validateField(field);
                });
            });
        });
    });
})();