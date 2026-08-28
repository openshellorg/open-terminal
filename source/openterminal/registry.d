/**
 * In-process association registry (localhost IPC stub later).
 */
module openterminal.registry;

import openterminal.association;

/// Working v0 registry — no sockets yet; proves register/subscribe/focus APIs.
final class InProcessAssociationRegistry : AssociationHandshake
{
	SessionRegistration[] registrations;
	ThumbnailSubscription[] subscriptions;
	string focusedSurfaceId;
	string[] log;

	override void register(SessionRegistration registration)
	{
		foreach (i, r; registrations)
		{
			if (r.groupId == registration.groupId)
			{
				registrations[i] = registration;
				log ~= "register(update) " ~ registration.groupId;
				return;
			}
		}
		registrations ~= registration;
		log ~= "register " ~ registration.groupId;
	}

	override void subscribe(ThumbnailSubscription subscription)
	{
		subscriptions ~= subscription;
		log ~= "subscribe " ~ subscription.subscriberId ~ " -> " ~ subscription.groupId;
	}

	override void unsubscribe(string subscriberId)
	{
		ThumbnailSubscription[] kept;
		foreach (s; subscriptions)
			if (s.subscriberId != subscriberId)
				kept ~= s;
		subscriptions = kept;
		log ~= "unsubscribe " ~ subscriberId;
	}

	override void focusSurface(string surfaceId)
	{
		focusedSurfaceId = surfaceId;
		log ~= "focus " ~ surfaceId;
	}
}
