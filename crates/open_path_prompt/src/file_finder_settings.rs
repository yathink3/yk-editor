use serde::Deserialize;
use settings::{ModalWidthContent, RegisterSetting, Settings};

#[derive(Deserialize, Debug, Clone, Copy, PartialEq, RegisterSetting)]
pub struct FileFinderSettings {
    pub file_icons: bool,
    pub modal_max_width: ModalWidthContent,
    pub skip_focus_for_active_in_search: bool,
    pub include_ignored: Option<bool>,
<<<<<<< 6f14586eaa5eb2db372a8f7595cf80d756f4f425
=======
    pub include_channels: bool,
    pub prefill_query_from_selection: bool,
>>>>>>> be207503599279ac40f5cf5d41d93ccb9e7beb0b
}

impl Settings for FileFinderSettings {
    fn from_settings(content: &settings::SettingsContent) -> Self {
        let file_finder = content.file_finder.as_ref().unwrap();

        Self {
            file_icons: file_finder.file_icons.unwrap(),
            modal_max_width: file_finder.modal_max_width.unwrap(),
            skip_focus_for_active_in_search: file_finder.skip_focus_for_active_in_search.unwrap(),
            include_ignored: match file_finder.include_ignored.unwrap() {
                settings::IncludeIgnoredContent::All => Some(true),
                settings::IncludeIgnoredContent::Indexed => Some(false),
                settings::IncludeIgnoredContent::Smart => None,
            },
<<<<<<< 6f14586eaa5eb2db372a8f7595cf80d756f4f425
=======
            include_channels: file_finder.include_channels.unwrap(),
            prefill_query_from_selection: file_finder.prefill_query_from_selection.unwrap(),
>>>>>>> be207503599279ac40f5cf5d41d93ccb9e7beb0b
        }
    }
}
