import 'dart:async';
import 'dart:io';
import 'package:dbus/dbus.dart';

import 'dbus_menu_object.dart';

/// Category for notifier items.
enum StatusNotifierItemCategory {
  applicationStatus,
  communications,
  systemServices,
  hardware
}

/// Status for notifier items.
enum StatusNotifierItemStatus { passive, active }

String _encodeCategory(StatusNotifierItemCategory value) =>
    {
      StatusNotifierItemCategory.applicationStatus: 'ApplicationStatus',
      StatusNotifierItemCategory.communications: 'Communications',
      StatusNotifierItemCategory.systemServices: 'SystemServices',
      StatusNotifierItemCategory.hardware: 'Hardware'
    }[value] ??
    '';

String _encodeStatus(StatusNotifierItemStatus value) =>
    {
      StatusNotifierItemStatus.passive: 'Passive',
      StatusNotifierItemStatus.active: 'Active'
    }[value] ??
    '';

const _kPropertyIconName = 'IconName';
const _kPropertyLabel = 'XAyatanaLabel';
const _kPropertyLabelGuide = 'XAyatanaLabelGuide';
const _kNotificationItemInterfaceName = 'org.kde.StatusNotifierItem';

class _StatusNotifierItemObject extends DBusObject {
  final StatusNotifierItemCategory category;
  final String id;
  String title;
  StatusNotifierItemStatus status;
  final int windowId;
  String iconName;
  String overlayIconName;
  String attentionIconName;
  String attentionMovieName;
  String label;
  String labelGuide;
  final DBusObjectPath menu;
  Future<void> Function(int x, int y)? onContextMenu;
  Future<void> Function(int x, int y)? onActivate;
  Future<void> Function(int x, int y)? onSecondaryActivate;
  Future<void> Function(int delta, String orientation)? onScroll;

  _StatusNotifierItemObject(
      {this.category = StatusNotifierItemCategory.applicationStatus,
      required this.id,
      this.title = '',
      this.status = StatusNotifierItemStatus.active,
      this.windowId = 0,
      this.iconName = '',
      this.overlayIconName = '',
      this.attentionIconName = '',
      this.attentionMovieName = '',
      this.label = '',
      this.labelGuide = '',
      this.menu = DBusObjectPath.root,
      this.onContextMenu,
      this.onActivate,
      this.onSecondaryActivate,
      this.onScroll})
      : super(DBusObjectPath('/StatusNotifierItem'));

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface(_kNotificationItemInterfaceName, methods: [
        DBusIntrospectMethod('ContextMenu', args: [
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'x'),
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'y')
        ]),
        DBusIntrospectMethod('Activate', args: [
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'x'),
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'y')
        ]),
        DBusIntrospectMethod('SecondaryActivate', args: [
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'x'),
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'y')
        ]),
        DBusIntrospectMethod('Scroll', args: [
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'delta'),
          DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_,
              name: 'orientation')
        ]),
        DBusIntrospectMethod('ProvideXdgActivationToken', args: [
          DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_,
              name: 'token')
        ])
      ], signals: [], properties: [
        DBusIntrospectProperty('Category', DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Id', DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Title', DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Status', DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('WindowId', DBusSignature('i'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty(_kPropertyIconName, DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('IconPixmap', DBusSignature('a(iiay)'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('OverlayIconName', DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('OverlayIconPixmap', DBusSignature('a(iiay)'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('AttentionIconName', DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('AttentionIconPixmap', DBusSignature('a(iiay)'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('AttentionMovieName', DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('ToolTip', DBusSignature('(sa(iiay))'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('ItemIsMenu', DBusSignature('b'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Menu', DBusSignature('o'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty(_kPropertyLabel, DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty(_kPropertyLabelGuide, DBusSignature('s'),
            access: DBusPropertyAccess.read),
      ])
    ];
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface != _kNotificationItemInterfaceName) {
      return DBusMethodErrorResponse.unknownInterface();
    }

    switch (methodCall.name) {
      case 'ContextMenu':
        if (methodCall.signature != DBusSignature('ii')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        var x = methodCall.values[0].asInt32();
        var y = methodCall.values[1].asInt32();
        await onContextMenu?.call(x, y);
        return DBusMethodSuccessResponse();
      case 'Activate':
        if (methodCall.signature != DBusSignature('ii')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        var x = methodCall.values[0].asInt32();
        var y = methodCall.values[1].asInt32();
        await onActivate?.call(x, y);
        return DBusMethodSuccessResponse();
      case 'SecondaryActivate':
        if (methodCall.signature != DBusSignature('ii')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        var x = methodCall.values[0].asInt32();
        var y = methodCall.values[1].asInt32();
        await onSecondaryActivate?.call(x, y);
        return DBusMethodSuccessResponse();
      case 'Scroll':
        if (methodCall.signature != DBusSignature('is')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        var delta = methodCall.values[0].asInt32();
        var orientation = methodCall.values[1].asString();
        await onScroll?.call(delta, orientation);
        return DBusMethodSuccessResponse();
      case 'ProvideXdgActivationToken':
        if (methodCall.signature != DBusSignature('s')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return DBusMethodSuccessResponse();
      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
  }

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    if (interface != _kNotificationItemInterfaceName) {
      return DBusMethodErrorResponse.unknownProperty();
    }

    switch (name) {
      case 'Category':
        return DBusGetPropertyResponse(DBusString(_encodeCategory(category)));
      case 'Id':
        return DBusGetPropertyResponse(DBusString(id));
      case 'Title':
        return DBusGetPropertyResponse(DBusString(title));
      case 'Status':
        return DBusGetPropertyResponse(DBusString(_encodeStatus(status)));
      case 'WindowId':
        return DBusGetPropertyResponse(DBusInt32(windowId));
      case _kPropertyIconName:
        return DBusGetPropertyResponse(DBusString(iconName));
      case 'IconPixmap':
        return DBusGetPropertyResponse(DBusArray(DBusSignature('(iiay)'), []));
      case 'OverlayIconName':
        return DBusGetPropertyResponse(DBusString(overlayIconName));
      case 'OverlayIconPixmap':
        return DBusGetPropertyResponse(DBusArray(DBusSignature('(iiay)'), []));
      case 'AttentionIconName':
        return DBusGetPropertyResponse(DBusString(attentionIconName));
      case 'AttentionIconPixmap':
        return DBusGetPropertyResponse(DBusArray(DBusSignature('(iiay)'), []));
      case 'AttentionMovieName':
        return DBusGetPropertyResponse(DBusString(attentionMovieName));
      case 'ToolTip':
        return DBusGetPropertyResponse(DBusStruct([
          DBusString(''),
          DBusArray(DBusSignature('(iiay)'), []),
          DBusString(''),
          DBusString('')
        ]));
      case 'ItemIsMenu':
        return DBusGetPropertyResponse(DBusBoolean(false));
      case 'Menu':
        return DBusGetPropertyResponse(menu);
      case _kPropertyLabel:
        return DBusGetPropertyResponse(DBusString(label));
      case _kPropertyLabelGuide:
        return DBusGetPropertyResponse(DBusString(labelGuide));
      default:
        return DBusMethodErrorResponse.unknownProperty();
    }
  }

  @override
  Future<DBusMethodResponse> getAllProperties(String interface) async {
    return DBusGetAllPropertiesResponse({
      'Category': DBusString(_encodeCategory(category)),
      'Id': DBusString(id),
      'Title': DBusString(title),
      'Status': DBusString(_encodeStatus(status)),
      'WindowId': DBusInt32(windowId),
      _kPropertyIconName: DBusString(iconName),
      'OverlayIconName': DBusString(overlayIconName),
      'AttentionIconName': DBusString(attentionIconName),
      'AttentionMovieName': DBusString(attentionMovieName),
      'ItemIsMenu': DBusBoolean(false),
      _kPropertyLabel: DBusString(label),
      _kPropertyLabelGuide: DBusString(labelGuide),
      'Menu': menu
    });
  }

  Future<void> setIconName(String value) async {
    if (value == iconName) return;
    iconName = value;
    await emitPropertiesChanged(_kNotificationItemInterfaceName, changedProperties: {_kPropertyIconName: DBusString(iconName)});
  }

  Future<void> setLabel(String label, [String guide = '']) async {
    if (label == this.label && labelGuide == guide) return;
    this.label = label;
    labelGuide = guide;
    await emitPropertiesChanged(_kNotificationItemInterfaceName, changedProperties: {
      _kPropertyLabel: DBusString(label),
      _kPropertyLabelGuide: DBusString(labelGuide),
    });
  }
}

/// A client that registers status notifier items.
class StatusNotifierItemClient {
  /// The bus this client is connected to.
  final DBusClient _bus;
  final bool _closeBus;

  late final DBusMenuObject _menuObject;
  late final _StatusNotifierItemObject _notifierItemObject;

  // FIXME: status enum
  /// Creates a new status notifier item client. If [bus] is provided connect to the given D-Bus server.
  StatusNotifierItemClient(
      {required String id,
      StatusNotifierItemCategory category =
          StatusNotifierItemCategory.applicationStatus,
      String title = '',
      StatusNotifierItemStatus status = StatusNotifierItemStatus.active,
      int windowId = 0,
      String iconName = '',
      String overlayIconName = '',
      String attentionIconName = '',
      String attentionMovieName = '',
      String label = '',
      String labelGuide = '',
      required DBusMenuItem menu,
      Future<void> Function(int x, int y)? onContextMenu,
      Future<void> Function(int x, int y)? onActivate,
      Future<void> Function(int x, int y)? onSecondaryActivate,
      Future<void> Function(int delta, String orientation)? onScroll,
      DBusClient? bus})
      : _bus = bus ?? DBusClient.session(),
        _closeBus = bus == null {
    _menuObject = DBusMenuObject(DBusObjectPath('/Menu'), menu);
    _notifierItemObject = _StatusNotifierItemObject(
        id: id,
        category: category,
        title: title,
        status: status,
        windowId: windowId,
        iconName: iconName,
        overlayIconName: overlayIconName,
        attentionIconName: attentionIconName,
        attentionMovieName: attentionMovieName,
        label: label,
        labelGuide: labelGuide,
        menu: _menuObject.path,
        onContextMenu: onContextMenu,
        onActivate: onActivate,
        onSecondaryActivate: onSecondaryActivate,
        onScroll: onScroll);
  }

  // Connect to D-Bus and register this notifier item.
  Future<void> connect() async {
    var name = 'org.kde.StatusNotifierItem-$pid-1';
    var requestResult = await _bus.requestName(name);
    assert(requestResult == DBusRequestNameReply.primaryOwner);

    // Register the menu.
    await _bus.registerObject(_menuObject);

    // Put the item on the bus.
    await _bus.registerObject(_notifierItemObject);

    // Register the item.
    await _bus.callMethod(
        destination: 'org.kde.StatusNotifierWatcher',
        path: DBusObjectPath('/StatusNotifierWatcher'),
        interface: 'org.kde.StatusNotifierWatcher',
        name: 'RegisterStatusNotifierItem',
        values: [DBusString(name)],
        replySignature: DBusSignature.empty);
  }

  /// Updates the menu shown.
  Future<void> updateMenu(DBusMenuItem menu) async {
    await _menuObject.update(menu);
  }

  Future<void> setIconName(String iconName) => _notifierItemObject.setIconName(iconName);

  Future<void> setLabel(String label, [String guide = '']) => _notifierItemObject.setLabel(label, guide);

  /// Terminates all active connections. If a client remains unclosed, the Dart process may not terminate.
  Future<void> close() async {
    if (_closeBus) {
      await _bus.close();
    }
  }
}
