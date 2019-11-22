use "fileExt"
use "ponytest"
use "files"
use "flow"

actor Main is TestList
	new create(env: Env) => PonyTest(env, this)
	new make() => None

	fun tag tests(test: PonyTest) =>
		test(_TestBitmap)


class iso _TestBitmap is UnitTest
	fun name(): String => "raw bitmap"

	fun apply(h: TestHelper) =>
		try
			let bitmap = Bitmap(100,100)
			bitmap.clear(RGBA.red())
			FileExt.cpointerToFile(bitmap, "/tmp/bitmap.raw")?
		end
	


