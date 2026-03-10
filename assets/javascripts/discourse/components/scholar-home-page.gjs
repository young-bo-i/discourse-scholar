import { i18n } from "discourse-i18n";
import ScholarLogo from "./scholar-logo";
import ScholarSearchBox from "./scholar-search-box";

const ScholarHomePage = <template>
  <div class="scholar-page scholar-home-page">
    <section class="scholar-home-page__hero">
      <h1 class="scholar-home-page__title">
        <ScholarLogo />
        <span class="scholar-home-page__title-text">
          {{i18n "scholar.home.title"}}
        </span>
      </h1>
      <p class="scholar-home-page__subtitle">
        {{i18n "scholar.home.subtitle"}}
      </p>
      <div class="scholar-home-page__search">
        <ScholarSearchBox />
      </div>
    </section>
  </div>
</template>;

export default ScholarHomePage;
