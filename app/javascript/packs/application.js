require("@rails/activestorage").start()
require("channels")


function hide(element) {
    element.style.display = "none";
}

function show(element) {
    element.style.display = "block";
}

window.addEventListener('load', () => {
    var initializerDiv = document.querySelector('div[data-control-type="spreedly-iframe-initializer"]');
    
    if(initializerDiv) {
        // Grab the data on the div: the token and the prefix
        const prefix = initializerDiv.dataset["prefix"];
        const envToken = initializerDiv.dataset["envToken"];
        const formSubmitName = initializerDiv.dataset["formSubmit"];

        // Grb some things we will use multiple places
        var spreedlySubmit = document.getElementById(`${prefix}_submit`);
        var formSubmit = document.getElementById(formSubmitName);
        const successDiv = document.getElementById(`${prefix}_success`);
        const errorDiv = document.getElementById(`${prefix}_errors`);
        const formDiv = document.getElementById(`${prefix}_form`);
        const tokenField = document.getElementById(`${prefix}_token`);
        const changePaymentButton = document.getElementById(`${prefix}_change_pm`);

        // Take over the "Add Payment Info" button
        spreedlySubmit.onclick = function() {
            const fullNameElement = document.getElementById(`${prefix}_full_name`);
            const expMonthElement = document.getElementById(`${prefix}_exp_month`);
            const expYearElement = document.getElementById(`${prefix}_exp_year`);

            var requiredFields = {
                full_name: fullNameElement.value,
                month: expMonthElement.value,
                year: expYearElement.value
            };
          
            window.Spreedly.tokenizeCreditCard(requiredFields);
            return false;
        };

        // Take over the "Change Payment Info" button
        changePaymentButton.onclick = function() {
            // Destroy the token
            tokenField.setAttribute("value", "");
            
            // Update visibilities
            hide(successDiv);
            show(formDiv)

            // Disable the submit button
            formSubmit.disabled = true;

            return false;
        }

        // Initially hide the errors and successes
        hide(errorDiv);
        hide(successDiv);

        // Hook up the completion method
        function receivePaymentToken(token, pmData) {
            // Hide the form div, show the success div
            show(successDiv);
            hide(formDiv);
            hide(errorDiv);

            // Add the card info to the success div
            document.getElementById(`${prefix}_card_type`).innerHTML = pmData.card_type;
            document.getElementById(`${prefix}_card_truncated`).innerHTML = pmData.last_four_digits;

            // Fill in the token
            tokenField.setAttribute("value", token);

            // Enable the submit button
            formSubmit.disabled = false;
        }

        // Set the payment token on completion
        window.Spreedly.on('paymentMethod', receivePaymentToken);

        // Alternatively, set the payment method based on server data
        var paymentMethodDiv = document.querySelector('div[data-control-type="spreedly-payment-method"]');
        if (paymentMethodDiv) {
            const cachedToken = paymentMethodDiv.dataset["token"];
            const cardType = paymentMethodDiv.dataset["cardType"];
            const lastFour = paymentMethodDiv.dataset["lastFour"];
            receivePaymentToken(cachedToken, { card_type: cardType, last_four_digits: lastFour });
        }

        // Display errors
        Spreedly.on('errors', function(errors) {
            errorDiv.innerHTML = errors.map(e => e.message).join("<br />");
            show(errorDiv);
        });

        // Initialize the spreedly iframes
        const numberElement = `${prefix}_number`;
        const cvvElement = `${prefix}_cvv`;
        window.Spreedly.init(envToken, { "numberEl": numberElement, "cvvEl": cvvElement });

        // When ready, reenable the submit button and change the styling.
        window.Spreedly.on("ready", function () {
            spreedlySubmit.disabled = false;

            const style = "width: 100%;  height: 44px; padding: 0px 20px; margin: 8px 0; box-sizing: border-box; border: 2px solid #ccc; border-radius: 4px;";
            Spreedly.setStyle("number", style);
            Spreedly.setStyle("cvv", style);
        });
    }
});

