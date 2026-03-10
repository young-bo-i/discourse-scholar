import { withPluginApi } from "discourse/lib/plugin-api";
import ScholarHeaderIcon from "../components/scholar-header-icon";

export default {
  name: "discourse-scholar-setup",
  initialize() {
    withPluginApi((api) => {
      api.headerIcons.add("scholar", ScholarHeaderIcon, {
        before: "search",
      });
    });
  },
};
