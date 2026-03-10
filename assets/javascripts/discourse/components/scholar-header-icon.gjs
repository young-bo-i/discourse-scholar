import Component from "@glimmer/component";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import icon from "discourse/helpers/d-icon";
import getURL from "discourse/lib/get-url";
import { i18n } from "discourse-i18n";

export default class ScholarHeaderIcon extends Component {
  @service router;
  @service siteSettings;

  get showIcon() {
    return this.siteSettings.discourse_scholar_enabled;
  }

  get href() {
    return getURL("/scholar");
  }

  <template>
    {{#if this.showIcon}}
      <li>
        <DButton
          @href={{this.href}}
          @icon="graduation-cap"
          title={{i18n "scholar.header.title"}}
          class="icon btn-flat scholar-forum-header-icon"
        />
      </li>
    {{/if}}
  </template>
}
