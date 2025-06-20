[CCode (cprefix = "X", gir_namespace = "xfixes", gir_version = "4.0", lower_case_cprefix = "X_")]
namespace X {
	namespace Fixes {
		[CCode (cheader_filename = "X11/extensions/Xfixes.h", cname = "XFixesCreateRegion")]
		public static X.XserverRegion create_region (X.Display display, [CCode (array_length = true)] X.Xrectangle[] rectangles);
		[CCode (cheader_filename = "X11/extensions/Xfixes.h", cname = "XFixesCreateRegionFromWindow")]
		public static X.XserverRegion create_region_from_window (X.Display display, X.Window window, int shape_kind);
		[CCode (cheader_filename = "X11/extensions/Xfixes.h", cname = "XFixesDestroyRegion")]
		public static void destroy_region (X.Display display, X.XserverRegion region);
		[CCode (cheader_filename = "X11/extensions/Xfixes.h", cname = "XFixesSetWindowShapeRegion")]
        public static void set_window_shape_region (X.Display display, X.Window win, int shape_kind, int x_off, int y_off, XserverRegion region);
	}
		namespace Shape {
		[CCode (cheader_filename = "X11/extensions/shape.h", cname = "XShapeGetRectangles")]
		public static X.Rectangle* get_rectangles (X.Display display, X.Window win, int kind, out int count, out int ordering);
		[CCode (cheader_filename = "X11/extensions/shape.h", cname = "XShapeCombineRectangles")]
		public static void combine_rectangles (X.Display display, X.Window win, int kind, int x, int y, [CCode (array_length_cname = "count", type = "XRectangle*")] X.Rectangle[] rectangles, int op, int ordering);
	}
	[SimpleType]
	[CCode (cheader_filename = "X11/extensions/Xfixes.h", cname = "XserverRegion", has_type_id = false)]
	public struct XserverRegion {
	}
	[SimpleType]
	[CCode (cheader_filename = "X11/Xlib.h", cname = "XRectangle", has_type_id = false)]
	public struct Xrectangle {
		public short x;
		public short y;
		public ushort width;
		public ushort height;
	}
}