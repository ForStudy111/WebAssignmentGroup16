/*
 * Shared client-side validation for the Counseling Management System.
 *
 * No gray validation hints are shown.
 * Invalid input shows only a red border and red error message.
 */
(function () {
    "use strict";

    let fieldCount = 0;

    function addStyles() {
        if (document.getElementById("validation-style")) {
            return;
        }

        const style = document.createElement("style");
        style.id = "validation-style";
        style.textContent = `
            .input-error {
                border: 1px solid #e74c3c !important;
                outline: none;
            }

            .field-error {
                display: block;
                margin-top: 6px;
                color: #e74c3c;
                font-size: 0.85rem;
                line-height: 1.35;
            }
        `;

        document.head.appendChild(style);
    }

    function getContainer(field) {
        return field.closest(".form-group") || field.parentElement;
    }

    function getKey(field) {
        if (!field.dataset.validationKey) {
            fieldCount++;
            field.dataset.validationKey = "validation-" + fieldCount;
        }

        return field.dataset.validationKey;
    }

    function clearError(field) {
        field.classList.remove("input-error");

        const key = getKey(field);

        getContainer(field).querySelectorAll(".field-error").forEach(function (error) {
            if (error.dataset.for === key) {
                error.remove();
            }
        });
    }

    function showError(field, message) {
        clearError(field);

        field.classList.add("input-error");

        const error = document.createElement("small");
        error.className = "field-error";
        error.dataset.for = getKey(field);
        error.textContent = message;

        getContainer(field).appendChild(error);
    }

    function getLabel(field) {
        return field.getAttribute("data-label")
                || field.name
                || "This field";
    }

    function isPhoneField(field) {
        return field.name === "phoneNumber"
                || field.getAttribute("data-validation") === "phone";
    }

    function isNewPasswordField(field) {
        if (field.getAttribute("data-password") === "true"
                || field.name === "newPassword") {
            return true;
        }

        /*
         * Applies to Register, Create User, and Add Counsellor.
         * Does not apply to the Login password field.
         */
        if (field.name === "password" && field.form) {
            return field.form.querySelector('[name="fullName"]')
                    || field.form.querySelector('[name="role"]')
                    || field.form.querySelector('[name="specialization"]')
                    || field.form.querySelector('[name="confirmPassword"]');
        }

        return false;
    }

    function setupConfirmPassword(form) {
        form.querySelectorAll('[name="confirmPassword"]').forEach(function (field) {
            if (!field.getAttribute("data-match")) {
                const passwordName = form.querySelector('[name="newPassword"]')
                        ? "newPassword"
                        : "password";

                field.setAttribute("data-match", passwordName);
            }
        });
    }

    function validateField(field, showRequiredError) {
        if (field.disabled
                || field.readOnly
                || field.type === "hidden"
                || field.type === "submit"
                || field.type === "button") {
            return true;
        }

        const value = (field.value || "").trim();
        const label = getLabel(field);

        if (value === "") {
            if (showRequiredError && field.required) {
                showError(field, label + " is required.");
                return false;
            }

            clearError(field);
            return true;
        }

        if (field.name === "username"
                && !/^[A-Za-z0-9_]{3,20}$/.test(value)) {
            showError(
                    field,
                    "Username must contain 3 to 20 letters, numbers, or underscores."
                    );
            return false;
        }

        if (field.name === "fullName" && value.length < 3) {
            showError(field, "Full name must contain at least 3 characters.");
            return false;
        }

        if ((field.type === "email" || field.name === "email")
                && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
            showError(field, "Please enter a valid email address.");
            return false;
        }

        if (isPhoneField(field)
                && !/^01[0-9]-\d{7,8}$/.test(value)) {
            showError(
                    field,
                    "Invalid phone number. Use 012-3456789 or 011-12345678."
                    );
            return false;
        }

        if (isNewPasswordField(field)
                && !/^(?=.*[A-Za-z])(?=.*\d)\S{6,}$/.test(value)) {
            showError(
                    field,
                    "Password needs at least 6 characters, 1 letter, 1 number, and no spaces."
                    );
            return false;
        }

        if (field.getAttribute("data-future-date") === "true") {
            const selectedDate = new Date(value + "T00:00:00");
            const today = new Date();

            today.setHours(0, 0, 0, 0);

            if (selectedDate < today) {
                showError(field, "Please choose today or a future date.");
                return false;
            }
        }

        const minimumLength = Number(field.getAttribute("data-minlength"));

        if (minimumLength > 0 && value.length < minimumLength) {
            showError(
                    field,
                    label + " must contain at least "
                    + minimumLength + " characters."
                    );
            return false;
        }

        if (field.getAttribute("data-rating") === "true"
                && (Number(value) < 1 || Number(value) > 5)) {
            showError(field, "Choose a rating from 1 to 5.");
            return false;
        }

        clearError(field);
        return true;
    }

    function validatePasswordMatch(form) {
        let isValid = true;

        form.querySelectorAll("[data-match]").forEach(function (confirmField) {
            const passwordName = confirmField.getAttribute("data-match");
            const passwordField = form.querySelector(
                    '[name="' + passwordName + '"]'
                    );

            if (confirmField.value === "") {
                clearError(confirmField);
                return;
            }

            if (passwordField
                    && confirmField.value !== passwordField.value) {
                showError(confirmField, "Passwords do not match.");
                isValid = false;
            } else {
                clearError(confirmField);
            }
        });

        return isValid;
    }

    function validateForm(form) {
        let isValid = true;

        form.querySelectorAll("input, select, textarea").forEach(function (field) {
            if (!validateField(field, true)) {
                isValid = false;
            }
        });

        if (!validatePasswordMatch(form)) {
            isValid = false;
        }

        return isValid;
    }

    function needsValidation(form) {
        return form.classList.contains("validate-form")
                || form.querySelector('[name="phoneNumber"]')
                || form.querySelector('[name="newPassword"]')
                || form.querySelector('[name="confirmPassword"]')
                || form.querySelector('[data-password="true"]');
    }

    function removeOnlyValidationHints() {
        const validationHintTexts = [
            "format: 012-3456789 or 011-12345678.",
            "at least 6 characters, including 1 letter and 1 number. no spaces.",
            "must match the new password."
        ];

        document.querySelectorAll(".field-hint").forEach(function (hint) {
            const text = hint.textContent.trim().toLowerCase();

            if (validationHintTexts.includes(text)) {
                hint.remove();
            }
        });
    }

    document.addEventListener("DOMContentLoaded", function () {
        addStyles();
        removeOnlyValidationHints();

        document.querySelectorAll("form").forEach(function (form) {
            if (!needsValidation(form)) {
                return;
            }

            form.noValidate = true;
            setupConfirmPassword(form);

            form.addEventListener("submit", function (event) {
                if (!validateForm(form)) {
                    event.preventDefault();
                }
            });

            form.querySelectorAll("input, select, textarea").forEach(function (field) {
                field.addEventListener("input", function () {
                    validateField(field, false);

                    if (isNewPasswordField(field)
                            || field.getAttribute("data-match") !== null) {
                        validatePasswordMatch(form);
                    }
                });

                field.addEventListener("change", function () {
                    validateField(field, false);
                });

                field.addEventListener("blur", function () {
                    validateField(field, true);
                });
            });
        });
    });
})();