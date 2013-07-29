#= require rails.validations

window.ClientSideValidations.formBuilders =
  "ActionView::Helpers::FormBuilder":
    add: (element, settings, message) ->
      form = $(element[0].form)
      if element.data("valid") isnt false and (form.find("label.message[for='" + (element.attr("id")) + "']").length?)
        labelErrorField = jQuery("<label class=\"message\"></label>").attr("for", element.attr("id"))
        element.closest(".field").addClass("field-error").append labelErrorField
      form.find("label.message[for='" + (element.attr("id")) + "']").text message

    remove: (element, settings) ->
      element.closest(".field").removeClass("field-error").find("label.message").remove()
