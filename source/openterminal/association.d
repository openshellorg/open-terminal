/**
 * Session association / thumbnail handshake stubs.
 *
 * Spec: openshellorg/shell-architecture session-association.adoc
 * No IPC transport yet -- types only for layout + registration sketches.
 */
module openterminal.association;

/// First-class host layout compositions.
enum LayoutMode : ubyte
{
	/// Classic Terminal-like: tabs top/left; tabs + surface may share one HWND.
	standalone = 0,
	/// Index window (tabs / thumbs); live sessions in separate OS windows.
	decoupledIndex = 1,
	/// Reserved for future compositions -- do not over-specify.
	other = 255,
}

/// Who produces live thumbnail frames for subscribers.
enum ThumbnailProducer : ubyte
{
	/// Session/host process creates thumbs; UIs subscribe (v0 ideal).
	sessionHost = 0,
	/// Subscriber captures (fallback; may be costly / less accurate).
	subscriber = 1,
	/// No thumbnails offered.
	none = 2,
}

/// One tab / session row in a registration payload.
struct TabDescriptor
{
	string id;
	string title;
	/// Opaque handle string for the live surface (HWND id, guid, etc.).
	string surfaceId;
}

/// Registration info sent during re-association handshake.
struct SessionRegistration
{
	string groupId;
	LayoutMode sourceLayout;
	TabDescriptor[] tabs;
	/// Whether thumbs are offered to this subscriber.
	bool thumbnailPermission;
	ThumbnailProducer thumbProducer = ThumbnailProducer.sessionHost;
	/// Optional shared-memory name / address token for thumb frames (TBD).
	string thumbnailShmAddress;
}

/// Subscriber interest (controller UI is not exclusive owner in v0).
struct ThumbnailSubscription
{
	string subscriberId;
	string groupId;
	/// Prefer session-produced shm thumbs when available.
	bool preferSharedMemory = true;
}

/// Handshake sketch -- wire later; no transport in scaffold.
interface AssociationHandshake
{
	/// Offer or accept registration (individual session or whole multi-tab UI).
	void register(SessionRegistration registration);

	/// Attach as subscriber (multiple subscribers allowed in v0).
	void subscribe(ThumbnailSubscription subscription);

	/// Drop subscriber interest; sessions remain running.
	void unsubscribe(string subscriberId);

	/// Focus / activate a registered surface (OS window).
	void focusSurface(string surfaceId);
}