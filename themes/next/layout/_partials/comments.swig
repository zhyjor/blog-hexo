{% if page.comments %}
  <div class="comments" id="comments">
    {% if theme.livere_uid %}
      <div id="lv-container" data-id="city" data-uid="{{ theme.livere_uid }}"></div>
	{% endif %}
  </div>
{% endif %}
