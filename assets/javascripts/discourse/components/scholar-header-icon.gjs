import Component from "@glimmer/component";
import { service } from "@ember/service";
import getURL from "discourse/lib/get-url";
import { i18n } from "discourse-i18n";
import ScholarLogo from "./scholar-logo";

export default class ScholarHeaderIcon extends Component {
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
        <a
          href={{this.href}}
          title={{i18n "scholar.header.title"}}
          class="icon btn-flat btn no-text scholar-forum-header-icon"
        >
          <ScholarLogo />
        </a>
      </li>
    {{/if}}
  </template>
}
