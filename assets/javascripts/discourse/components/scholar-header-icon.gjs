import Component from "@glimmer/component";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";
import ScholayBrandLogo from "./scholay-brand-logo";

export default class ScholarHeaderIcon extends Component {
  @service siteSettings;

  get showIcon() {
    return this.siteSettings.discourse_scholar_enabled;
  }

  <template>
    {{#if this.showIcon}}
      <li>
        <a
          href="https://www.scholay.com/"
          target="_blank"
          rel="noopener noreferrer"
          title={{i18n "scholar.header.scholay_link"}}
          class="icon btn-flat btn no-text scholar-forum-header-icon"
        >
          <ScholayBrandLogo />
        </a>
      </li>
    {{/if}}
  </template>
}
