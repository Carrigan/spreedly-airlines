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

        // Take over the button
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

        // Initially hide the errors and successes
        hide(errorDiv);
        hide(successDiv);

        // Hook up the completion method
        window.Spreedly.on('paymentMethod', function(token, pmData) {
            // Hide the form div, show the success div with card info
            show(successDiv);
            hide(document.getElementById(`${prefix}_form`));
            hide(errorDiv);
            document.getElementById(`${prefix}_card_type`).innerHTML = pmData.card_type;
            document.getElementById(`${prefix}_card_truncated`).innerHTML = pmData.last_four_digits;

            // Fill in the token
            var tokenField = document.getElementById(`${prefix}_token`);
            tokenField.setAttribute("value", token);

            // Enable the submit button
            formSubmit.disabled = false;
        });

        // Display errors
        Spreedly.on('errors', function(errors) {
            errorDiv.innerHTML = errors.map(e => e.message).join("<br />");
            show(errorDiv);
        });

        // Initialize the spreedly iframes
        const numberElement = `${prefix}_number`;
        const cvvElement = `${prefix}_cvv`;
        window.Spreedly.init(envToken, { "numberEl": numberElement, "cvvEl": cvvElement });

        // When ready, reenable the submit buttton
        window.Spreedly.on("ready", function () {
            spreedlySubmit.disabled = false;
        });
    }
});

