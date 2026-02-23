# GuildSync - Changelog

## [2.0.5] - 2026-02-23

### Bug Fixes
- **Nil-Value Error Fix**: Fixed a crash in `GuildSync.lua` when receiving a `RECORD` message with missing data.
- **Robustness**: Added additional nil-checks in the difficulty verification logic to prevent potential errors with incomplete player data.

## [2.0.4] - 2024-02-21

### Simplified Synchronization Mechanism
- **Initial PULL on Load**: When the addon is loaded (`PLAYER_ENTERING_WORLD`), a `PULL` request is now automatically sent to the guild to request current data.
- **Push-on-Change**: Data (lockouts and quests) is only sent to the guild when an actual change in your own status is detected.
- **Optimized Triggers**: A sync is triggered on login, zone changes (`ZONE_CHANGED_NEW_AREA`), quest completions, and instance info updates – but only if the data has changed.
- **Efficiency**: A fast comparison of serialized data structures is used to detect changes and avoid unnecessary network traffic.

### Version Checking & Update Notifications
- **Version Tracking**: The addon version is now included with every outgoing message.
- **Update Notification**: The addon now checks incoming messages to see if a newer version is available.
- **Chat Notice**: If a newer version is detected, a yellow system message appears in the chat once per session.

### Refactoring & Cleanup
- **Global Renaming**: All internal references have been changed from `GID` to `GS` (GuildSync).
- **Prefix Update**: The communication prefix has been changed to `GS`.
- **Command Cleanup**: Outdated references to `/gid update` have been removed, as synchronization is now fully automatic in the background.
- **Command Update**: All slash commands have been unified to `/gs` (e.g., `/gs show`, `/gs own`, `/gs all`, `/gs clear`).

### Bug Fixes
- Corrected a loop error in capturing instance IDs.
- Stabilized difficulty detection for TBC Anniversary (2.5.5).

---

## [1.0.4]
- The addon has been renamed from **GuildIDSync** to **GuildSync**. All files and saved variables have been migrated accordingly.
- **Migration**: Existing settings from *GuildIDSyncDB* are automatically imported into *GuildSyncDB*.
- **Settings Tab**: Added a new settings tab to configure addon behavior.
- **Slash Commands**: Replaced old `/gid` commands with a single `/gs` command to toggle the UI.
- Version number updated to **1.0.4**.

### [UI & Design]
- **Switch to Standard Blizzard UI**: The main window now uses the *ButtonFrameTemplate* for a consistent look & feel.
- **Tab System Introduced**: Toggle between **IDs/Lockouts**, **Layering**, and **Settings** tabs at the bottom of the window.
- **Tabular Lockout View**: The ID display has been changed from blocks to a sortable table (Player, Level, ID, Reset, Whisper, Invite).
- **Automatic Clearing**: When changing the instance category in the dropdown, the right-side view is now cleared immediately to avoid confusion.

### [Layering System]
- **New Layering Tab**: Displays all online guild members with their zone and current layer.
- **NPC-based Layer Detection**: Custom, precise logic to determine the layer by targeting or mouseovering NPCs (independent of NovaWorldBuffs).
- **Live Updates**: Your own layer is updated in the UI immediately as soon as it is detected.
- **Layer Invites**: Players can be requested directly from the list to initiate a layer switch. The "Request Layer switch" button is now automatically disabled if the player is already on the same layer.
- **Confirmation Dialog**: Added a confirmation popup when receiving a layer switch request to prevent unintended group invites.
- **Auto-Accept (Option)**: Added an option in the Settings tab to automatically accept layer switch requests from guild members.
- **Auto-Accept (Requester)**: The requester now automatically accepts the group invitation if it comes from the requested player within 30 seconds.
- **Refresh Logic**: Manual refresh button with a 30s cooldown and automatic refresh for outdated data (>5 min).
- **Layer Safety**: Queries to guild members are now only sent if your own layer is known. Otherwise, a prompt to target an NPC is displayed.

### [Minimap Button]
- **Independent Implementation**: The minimap button now functions without external libraries (LibDBIcon removed).
- **Visibility**: Added a setting to hide/show the minimap button.
- **Design Update**: New icon with "GS" initials on a dark background.
- **Improved Dragging**: The button can now be freely positioned and is compatible with square minimaps (ElvUI, SexyMap).
- **Persistence**: Exact X/Y offsets are stored to maintain position across custom UI scales.

### [Technical & Performance]
- **Optimized Lockout Sync**: Lockout updates are no longer sent on every zone change. Updates are now only triggered on initial login, when an instance ID is acquired, or when a relevant PvP quest is completed.
- **AceSerializer-3.0**: Switched from LibSerialize to the Ace standard for more stable data transmission.
- **LibDeflate Integration**: Highly efficient compression of addon data to reduce traffic in the guild channel.
- **Gossip Protocol**: Efficient synchronization of lockout data using manifest buckets to save bandwidth.
- **Reduced Dependencies**: Unnecessary libraries have been removed to make the addon leaner.
