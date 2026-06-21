/*
 * Shared client-side validation.
 * Use it only on forms with: class="validate-form"
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
                || field.type === "hidden"
                || field.type === "submit"
                || field.type === "button") {
            return true;
        }

        const value = (field.value || "").trim();

        if (field.required && value === "") {
            showError(field, getLabel(field) + " is required.");
            return false;
        }

        if (field.type === "email"
                && value !== ""
                && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {

            showError(field, "Please enter a valid email address.");
            return false;
        }

        if (field.getAttribute("data-validation") === "phone"
                && value !== ""
                && !/^[0-9+\-\s]{8,20}$/.test(value)) {

            showError(field,
                    "Enter a valid phone number using 8 to 20 digits.");
            return false;
        }

        if (field.getAttribute("data-password") === "true"
                && value !== ""
                && value.length < 6) {

            showError(field,
                    "Password must contain at least 6 characters.");
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