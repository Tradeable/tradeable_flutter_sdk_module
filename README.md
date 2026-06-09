# tradeable_flutter_sdk_module

Flutter module used by native iOS and Android hosts.

## New Views Added

The module currently supports these mode values in incoming view state:

- `direct`
- `card`
- `fullscreen`
- `dashboard`
- `sidedrawer`
- `tradeablesidedrawer`
- `nativeSideDrawer`

Current behavior:

1. Native can open side drawer and pass `pageId`.
2. In `nativeSideDrawer` mode, topic taps emit host navigation events instead of navigating inside drawer.
3. Native host opens a new fullscreen screen for topic details or dashboard.

## Method Channels

Channel names:

- `embedded_flutter`
- `embedded_flutter/auth`
- `embedded_flutter/navigation`

### Host -> Flutter Methods

#### Channel: `embedded_flutter`

`setData(args: Map<String, dynamic>)`

- `mode` (`String`, optional): one of `direct`, `card`, `fullscreen`, `dashboard`, `sidedrawer`, `tradeablesidedrawer`, `nativeSideDrawer`
- `text` (`String`, optional)
- `width` (`double`, optional)
- `height` (`double`, optional)
- `topicId` (`int`, optional)
- `pageId` (`int | String`, optional) (`pageID` is also accepted)

#### Channel: `embedded_flutter/auth`

`initializeTFS(args: Map<String, dynamic>)`

- `baseUrl` (`String`, optional but required for first-time init)
- `authToken` (`String`, required for app registration)
- `portalToken` (`String`, required for app registration)
- `appId` (`String`, required for app registration)
- `clientId` (`String`, required for app registration)
- `publicKey` (`String`, required for app registration)

#### Channel: `embedded_flutter/navigation`

`openTradeableSideDrawer(args: Map<String, dynamic> | int)`

- If map: include `pageId` (and any optional payload)
- If int: treated as `pageId`

`navigateTo(args: Map<String, dynamic>)`

- `route` (`String`, expected)
- `arguments` (`Map<String, dynamic>`, optional)

`replaceRoute(args: Map<String, dynamic>)`

- `route` (`String`, expected)
- `arguments` (`Map<String, dynamic>`, optional)

`popToRoot(args: Map<String, dynamic>)`

- `route` (`String`, optional)
- `arguments` (`Map<String, dynamic>`, optional)

`receiveData(args: Map<String, dynamic>)`

- Arbitrary payload forwarded to module state

### Flutter -> Host Methods

#### Channel: `embedded_flutter`

- `closeCard()`
- `closeFullscreen()`
- `closeSideDrawer()`

#### Channel: `embedded_flutter/navigation`

`sendData(args: Map<String, dynamic>)`

Examples:

- Topic open:
  - `{ "action": "openTopic", "topicId": 123, "title": "Topic Title" }`
- Dashboard open:
  - `{ "action": "openDashboard", "title": "Learn Dashboard" }`

## Integration Notes

When embedding in native apps:

1. Initialize the channels before rendering Flutter content.
2. Send initial view state through `setData`.
3. Handle `sendData` and close callbacks in native to control drawer/fullscreen transitions.
