/*
 * Minimal WinRT camera-enumeration classes for Wine.
 *
 * LightBurn 2.x enumerates and watches cameras at start-up through
 *   Windows.Media.Capture.Frames.MediaFrameSourceGroup (not in Wine) and
 *   Windows.Devices.Enumeration.DeviceInformation (Wine's DeviceWatcher
 *   returns E_NOTIMPL for some event registrations),
 * and crashes on the resulting uncaught C++/WinRT exceptions. This DLL
 * implements both classes as "no devices present": every enumeration
 * returns an empty list and a device watcher that accepts all handlers
 * but never reports anything. LightBurn then starts without camera
 * support.
 *
 * Build: x86_64-w64-mingw32-gcc -shared -O2 -o winrt-capture-stub.dll \
 *            winrt-capture-stub.c
 *
 * Copyright 2026 Gert Pellin
 * Distributed under the terms of the GNU General Public License v2
 */

#include <windows.h>

typedef void *HSTRING;
typedef enum { AsyncCompleted = 1 } AsyncStatus;
typedef struct { INT64 value; } EventRegistrationToken;

#define DEFINE_IID(name, l, w1, w2, b0, b1, b2, b3, b4, b5, b6, b7) \
	static const GUID name = { l, w1, w2, { b0, b1, b2, b3, b4, b5, b6, b7 } }

DEFINE_IID(IID_IUnknown_, 0x00000000, 0x0000, 0x0000, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46);
DEFINE_IID(IID_IInspectable_, 0xaf86e2e0, 0xb12d, 0x4c6a, 0x9c, 0x5a, 0xd7, 0xaa, 0x65, 0x10, 0x1e, 0x90);
DEFINE_IID(IID_IAgileObject_, 0x94ea2b94, 0xe9cc, 0x49e0, 0xc0, 0xff, 0xee, 0x64, 0xca, 0x8f, 0x5b, 0x90);
DEFINE_IID(IID_IActivationFactory_, 0x00000035, 0x0000, 0x0000, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46);
DEFINE_IID(IID_IAsyncInfo_, 0x00000036, 0x0000, 0x0000, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46);

/* Windows.Media.Capture.Frames.MediaFrameSourceGroup
 * (default interface {7f605b87-4832-4b5f-ae3d-412faab37d34}) */
DEFINE_IID(IID_IMediaFrameSourceGroupStatics, 0x1c48bfc5, 0x436f, 0x4508, 0x94, 0xcf, 0xd5, 0xd8, 0xb7, 0x32, 0x64, 0x45);
DEFINE_IID(IID_IVectorView_MFSG, 0xd01148ae, 0xcccd, 0x56eb, 0xb2, 0xb4, 0xa7, 0xd2, 0xac, 0xce, 0x14, 0xec);
DEFINE_IID(IID_IIterable_MFSG, 0xd0b71deb, 0x76e8, 0x5833, 0x96, 0x23, 0x2b, 0x1e, 0x1a, 0x8e, 0x1b, 0x72);
DEFINE_IID(IID_IIterator_MFSG, 0xdc0c1f9a, 0xb748, 0x5cfa, 0x9b, 0x42, 0xa3, 0xa8, 0xfe, 0x37, 0x28, 0x1a);
DEFINE_IID(IID_IAsyncOperation_VV_MFSG, 0xa795889f, 0x6d49, 0x5687, 0xaa, 0xbe, 0xf2, 0xfc, 0x62, 0x37, 0xfa, 0x1a);

/* Windows.Devices.Enumeration.DeviceInformation
 * (default interface {aba0fb95-4398-489d-8e44-e6130927011f}) */
DEFINE_IID(IID_IDeviceInformationStatics, 0xc17f100e, 0x3a46, 0x4a78, 0x80, 0x13, 0x76, 0x9d, 0xc9, 0xb9, 0x73, 0x90);
DEFINE_IID(IID_IDeviceWatcher, 0xc9eab97d, 0x8f6b, 0x4f96, 0xa9, 0xf4, 0xab, 0xc8, 0x14, 0xe2, 0x22, 0x71);
DEFINE_IID(IID_IVectorView_DI, 0xe170688f, 0x3495, 0x5bf6, 0xaa, 0xb5, 0x9c, 0xac, 0x17, 0xe0, 0xf1, 0x0f);
DEFINE_IID(IID_IIterable_DI, 0xdd9f8a5d, 0xec98, 0x5f4b, 0xa3, 0xea, 0x9c, 0x8b, 0x5a, 0xd5, 0x3c, 0x4b);
DEFINE_IID(IID_IAsyncOperation_DIColl, 0x45180254, 0x082e, 0x5274, 0xb2, 0xe7, 0xac, 0x05, 0x17, 0xf4, 0x4d, 0x07);

/* ------------------------------------------------------------------ */
/* All objects are static singletons without reference counting. Each
 * object knows the interface it implements and an optional "sibling"
 * object for a second interface of the same runtime object.           */

typedef struct object object;
struct object {
	const void *vtbl;
	const GUID *iid;        /* interface implemented by this vtable */
	const GUID *other_iid;  /* second interface of the runtime object */
	object *other;          /* ...implemented by this object */
	void *data;             /* object specific */
};

#define PRIV(o) ((object *)(o))

static HRESULT WINAPI obj_qi(object *this, const GUID *iid, void **out)
{
	if (IsEqualGUID(iid, &IID_IUnknown_) || IsEqualGUID(iid, &IID_IInspectable_) ||
	    IsEqualGUID(iid, &IID_IAgileObject_) || IsEqualGUID(iid, this->iid)) {
		*out = this;
		return S_OK;
	}
	if (this->other_iid && IsEqualGUID(iid, this->other_iid)) {
		*out = this->other;
		return S_OK;
	}
	*out = NULL;
	return E_NOINTERFACE;
}
static ULONG WINAPI obj_addref(object *this) { return 2; }
static ULONG WINAPI obj_release(object *this) { return 1; }
static HRESULT WINAPI obj_getiids(object *this, ULONG *count, GUID **iids)
{ *count = 0; *iids = NULL; return S_OK; }
static HRESULT WINAPI obj_getclassname(object *this, HSTRING *name) { *name = NULL; return S_OK; }
static HRESULT WINAPI obj_gettrustlevel(object *this, int *level) { *level = 0; return S_OK; }

#define INSPECTABLE_METHODS \
	obj_qi, obj_addref, obj_release, obj_getiids, obj_getclassname, obj_gettrustlevel

/* ------------------------------------------------------------------ */
/* empty IVectorView<T> / IIterable<T> / IIterator<T>                  */

static HRESULT WINAPI it_get_current(object *this, void **item) { *item = NULL; return E_BOUNDS; }
static HRESULT WINAPI it_get_hascurrent(object *this, boolean *has) { *has = FALSE; return S_OK; }
static HRESULT WINAPI it_movenext(object *this, boolean *has) { *has = FALSE; return S_OK; }
static HRESULT WINAPI it_getmany(object *this, UINT32 n, void **items, UINT32 *got)
{ *got = 0; return S_OK; }
static const void *iterator_vtbl[] = {
	INSPECTABLE_METHODS, it_get_current, it_get_hascurrent, it_movenext, it_getmany,
};

static HRESULT WINAPI vv_getat(object *this, UINT32 i, void **item) { *item = NULL; return E_BOUNDS; }
static HRESULT WINAPI vv_get_size(object *this, UINT32 *size) { *size = 0; return S_OK; }
static HRESULT WINAPI vv_indexof(object *this, void *item, UINT32 *index, boolean *found)
{ *index = 0; *found = FALSE; return S_OK; }
static HRESULT WINAPI vv_getmany(object *this, UINT32 start, UINT32 n, void **items, UINT32 *got)
{ *got = 0; return S_OK; }
static const void *vectorview_vtbl[] = {
	INSPECTABLE_METHODS, vv_getat, vv_get_size, vv_indexof, vv_getmany,
};

/* data = the iterator object */
static HRESULT WINAPI itb_first(object *this, void **it) { *it = this->data; return S_OK; }
static const void *iterable_vtbl[] = { INSPECTABLE_METHODS, itb_first };

/* ------------------------------------------------------------------ */
/* already completed IAsyncOperation<T> + IAsyncInfo                   */

typedef struct handler handler;
struct handler {
	const struct {
		HRESULT (WINAPI *QueryInterface)(handler *, const GUID *, void **);
		ULONG (WINAPI *AddRef)(handler *);
		ULONG (WINAPI *Release)(handler *);
		HRESULT (WINAPI *Invoke)(handler *, void *sender, AsyncStatus status);
	} *vtbl;
};

static HRESULT WINAPI op_put_completed(object *this, handler *h)
{
	if (h)
		h->vtbl->Invoke(h, this, AsyncCompleted);
	return S_OK;
}
static HRESULT WINAPI op_get_completed(object *this, handler **h) { *h = NULL; return S_OK; }
/* data = the result object */
static HRESULT WINAPI op_getresults(object *this, void **result) { *result = this->data; return S_OK; }
static const void *asyncop_vtbl[] = {
	INSPECTABLE_METHODS, op_put_completed, op_get_completed, op_getresults,
};

static HRESULT WINAPI info_get_id(object *this, UINT32 *id) { *id = 1; return S_OK; }
static HRESULT WINAPI info_get_status(object *this, AsyncStatus *s) { *s = AsyncCompleted; return S_OK; }
static HRESULT WINAPI info_get_errorcode(object *this, HRESULT *hr) { *hr = S_OK; return S_OK; }
static HRESULT WINAPI info_cancel(object *this) { return S_OK; }
static HRESULT WINAPI info_close(object *this) { return S_OK; }
static const void *asyncinfo_vtbl[] = {
	INSPECTABLE_METHODS, info_get_id, info_get_status, info_get_errorcode, info_cancel, info_close,
};

/* empty list + completed operation returning it, for one element type */
#define EMPTY_LIST_OP(prefix, vv_iid, itb_iid, it_iid, op_iid) \
	static object prefix##_iterator = { iterator_vtbl, it_iid, NULL, NULL, NULL }; \
	static object prefix##_iterable; \
	static object prefix##_list = { vectorview_vtbl, vv_iid, itb_iid, &prefix##_iterable, NULL }; \
	static object prefix##_iterable = { iterable_vtbl, itb_iid, vv_iid, &prefix##_list, &prefix##_iterator }; \
	static object prefix##_info; \
	static object prefix##_op = { asyncop_vtbl, op_iid, &IID_IAsyncInfo_, &prefix##_info, &prefix##_list }; \
	static object prefix##_info = { asyncinfo_vtbl, &IID_IAsyncInfo_, op_iid, &prefix##_op, NULL };

DEFINE_IID(IID_IIterator_DI, 0x00000000, 0x0000, 0x0000, 0, 0, 0, 0, 0, 0, 0, 0); /* never queried */

EMPTY_LIST_OP(mfsg, &IID_IVectorView_MFSG, &IID_IIterable_MFSG, &IID_IIterator_MFSG,
	&IID_IAsyncOperation_VV_MFSG)
EMPTY_LIST_OP(di, &IID_IVectorView_DI, &IID_IIterable_DI, &IID_IIterator_DI,
	&IID_IAsyncOperation_DIColl)

/* ------------------------------------------------------------------ */
/* IDeviceWatcher that never sees a device                             */

typedef enum { WatcherCreated = 0, WatcherStarted = 1, WatcherStopped = 5 } WatcherStatus;
static WatcherStatus watcher_status = WatcherCreated;
static INT64 next_token = 1;

static HRESULT WINAPI w_add(object *this, void *handler, EventRegistrationToken *token)
{ token->value = next_token++; return S_OK; }
static HRESULT WINAPI w_remove(object *this, EventRegistrationToken token) { return S_OK; }
static HRESULT WINAPI w_get_status(object *this, WatcherStatus *status)
{ *status = watcher_status; return S_OK; }
static HRESULT WINAPI w_start(object *this) { watcher_status = WatcherStarted; return S_OK; }
static HRESULT WINAPI w_stop(object *this) { watcher_status = WatcherStopped; return S_OK; }
static const void *watcher_vtbl[] = {
	INSPECTABLE_METHODS,
	w_add, w_remove,	/* Added */
	w_add, w_remove,	/* Updated */
	w_add, w_remove,	/* Removed */
	w_add, w_remove,	/* EnumerationCompleted */
	w_add, w_remove,	/* Stopped */
	w_get_status, w_start, w_stop,
};
static object watcher = { watcher_vtbl, &IID_IDeviceWatcher, NULL, NULL, NULL };

/* ------------------------------------------------------------------ */
/* statics                                                              */

static HRESULT WINAPI mfsg_findallasync(object *this, void **op) { *op = &mfsg_op; return S_OK; }
static HRESULT WINAPI mfsg_fromidasync(object *this, HSTRING id, void **op)
{ *op = NULL; return E_NOTIMPL; }
static HRESULT WINAPI mfsg_getdeviceselector(object *this, HSTRING *sel) { *sel = NULL; return S_OK; }
static const void *mfsg_statics_vtbl[] = {
	INSPECTABLE_METHODS, mfsg_findallasync, mfsg_fromidasync, mfsg_getdeviceselector,
};

static HRESULT WINAPI di_createfromid(object *this, HSTRING id, void **op) { *op = NULL; return E_NOTIMPL; }
static HRESULT WINAPI di_createfromid2(object *this, HSTRING id, void *props, void **op)
{ *op = NULL; return E_NOTIMPL; }
static HRESULT WINAPI di_findall(object *this, void **op) { *op = &di_op; return S_OK; }
static HRESULT WINAPI di_findall1(object *this, INT32 a, void **op) { *op = &di_op; return S_OK; }
static HRESULT WINAPI di_findall2(object *this, void *a, void *b, void **op) { *op = &di_op; return S_OK; }
static HRESULT WINAPI di_watch(object *this, void **w) { *w = &watcher; return S_OK; }
static HRESULT WINAPI di_watch1(object *this, INT32 a, void **w) { *w = &watcher; return S_OK; }
static HRESULT WINAPI di_watch2(object *this, void *a, void *b, void **w) { *w = &watcher; return S_OK; }
static const void *di_statics_vtbl[] = {
	INSPECTABLE_METHODS,
	di_createfromid, di_createfromid2,
	di_findall, di_findall1 /* DeviceClass */, di_findall1 /* AQS filter */, di_findall2,
	di_watch, di_watch1 /* DeviceClass */, di_watch1 /* AQS filter */, di_watch2,
};

static HRESULT WINAPI fac_activateinstance(object *this, void **instance)
{ *instance = NULL; return E_NOTIMPL; }
static const void *factory_vtbl[] = { INSPECTABLE_METHODS, fac_activateinstance };

static object mfsg_statics, mfsg_factory = { factory_vtbl, &IID_IActivationFactory_,
	&IID_IMediaFrameSourceGroupStatics, &mfsg_statics, NULL };
static object mfsg_statics = { mfsg_statics_vtbl, &IID_IMediaFrameSourceGroupStatics,
	&IID_IActivationFactory_, &mfsg_factory, NULL };

static object di_statics, di_factory = { factory_vtbl, &IID_IActivationFactory_,
	&IID_IDeviceInformationStatics, &di_statics, NULL };
static object di_statics = { di_statics_vtbl, &IID_IDeviceInformationStatics,
	&IID_IActivationFactory_, &di_factory, NULL };

/* ------------------------------------------------------------------ */

typedef const WCHAR *(WINAPI *WindowsGetStringRawBuffer_t)(HSTRING, UINT32 *);

__declspec(dllexport) HRESULT WINAPI DllGetActivationFactory(HSTRING classid, void **out)
{
	static WindowsGetStringRawBuffer_t get_raw;
	const WCHAR *name;

	if (!get_raw)
		get_raw = (WindowsGetStringRawBuffer_t)GetProcAddress(
			LoadLibraryW(L"combase.dll"), "WindowsGetStringRawBuffer");
	name = get_raw ? get_raw(classid, NULL) : NULL;

	if (name && !lstrcmpW(name, L"Windows.Devices.Enumeration.DeviceInformation"))
		*out = &di_factory;
	else if (name && !lstrcmpW(name, L"Windows.Media.Capture.Frames.MediaFrameSourceGroup"))
		*out = &mfsg_factory;
	else {
		*out = NULL;
		return CLASS_E_CLASSNOTAVAILABLE;
	}
	return S_OK;
}

__declspec(dllexport) HRESULT WINAPI DllCanUnloadNow(void)
{
	return S_FALSE;
}
