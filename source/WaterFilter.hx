package;


// import lime._internal.graphics.ImageDataUtil;
import openfl.Lib;
import openfl.display.BitmapDataChannel;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import openfl.display.BitmapData;
import openfl.display.DisplayObjectRenderer;
import openfl.display.Shader;
import openfl.filters.BitmapFilter;
import openfl.filters.BitmapFilterShader;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

@:access(openfl.geom.Point)
@:access(openfl.geom.Rectangle)


class WaterFilter extends BitmapFilter
{
	@:noCompletion private static var __waterShader = new WaterShader();
	
	/**
	 * Level of liquid (goes downwards, so 0 means full "aquarium")
	 */
	public var waterLevel(get, set):Int;
	/**
	 * The ampliture of waves in water, more means stronger waves
	 */
	public var waveAmplitude(get, set):Int;
	/**
	 * The period of waves, more means slower waves
	 */
	public var wavePeriod(get, set):Float;
	/**
	 * The wave's length, more means "longer" waves
	 */
	public var waveLenght(get, set):Int;
	/**
	 * The wave's step, more means more "blocky" waves, less means smoother waves
	 */
	public var waveStep(get, set):Int;
	
	@:noCompletion private var __waterLevel:Int = 0;
	@:noCompletion private var __waveAmplitude:Int = 0;
	@:noCompletion private var __wavePeriod:Float = 0;
	@:noCompletion private var __waveOmega:Float = 0;
	@:noCompletion private var __waveLength:Int = 0;
	@:noCompletion private var __waveStep:Int = 0;
	
	/**
	 * "Water" filter constructor
	 * 
	 * @param	waterLevel		Level of liquid (goes downwards, so 0 means full "aquarium")
	 * @param	waveAmplitude	The ampliture of waves in water, more means stronger waves
	 * @param	wavePeriod		The period of waves, more means slower waves
	 * @param	waveLength		The wave's length, more means "longer" waves
	 * @param	waveStep		The wave's step, more means more "blocky" waves, less means smoother waves
	 */
	public function new(waterLevel:Int = 0, waveAmplitude:Int = 10, wavePeriod:Float = 10.0, waveLength:Int = 100, waveStep:Int = 10) 
	{	
		super();
		
		__waterLevel = waterLevel;
		__waveAmplitude = waveAmplitude;
		__wavePeriod = wavePeriod;
		__waveOmega = 2 * Math.PI / wavePeriod;
		__waveLength = waveLength;
		__waveStep = waveStep;
		
		__needSecondBitmapData = false;
		__preserveObject = false;
		__renderDirty = true;
		
		__numShaderPasses = 1;
	}
	
	public function setDirty():Void
	{
		__renderDirty = true;
	}
	
	public override function clone():BitmapFilter 
	{
		return new WaterFilter(__waterLevel, __waveAmplitude, __wavePeriod, __waveLength, __waveStep);
	}
	
	@:noCompletion private override function __applyFilter(bitmapData:BitmapData, sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point):BitmapData 
	{
		// TODO
		return bitmapData;
	}
	
	@:noCompletion private override function __initShader(renderer:DisplayObjectRenderer, pass:Int):Shader 
	{
		#if !macro
		__waterShader.uWaterLevel.value = [__waterLevel];
		__waterShader.uTime.value = [Lib.getTimer() / 1000];
		__waterShader.uWaveAmp.value = [__waveAmplitude];
		__waterShader.uWaveOmega.value = [__waveOmega];
		__waterShader.uWaveLength.value = [__waveLength];
		__waterShader.uWaveStep.value = [__waveStep];
		#end
		
		return __waterShader;
	}
	
	// Get & Set Methods
	
	@:noCompletion private function get_waterLevel():Int
	{
		return __waterLevel;
	}
	
	@:noCompletion private function set_waterLevel(value:Int):Int 
	{	
		if (value != __waterLevel) __renderDirty = true;
		return __waterLevel = value;
	}
	
	@:noCompletion private function get_waveAmplitude():Int
	{
		return __waveAmplitude;
	}
	
	@:noCompletion private function set_waveAmplitude(value:Int):Int 
	{	
		if (value != __waveAmplitude) __renderDirty = true;
		return __waveAmplitude = value;
	}
	
	@:noCompletion private function get_wavePeriod():Float
	{
		return __wavePeriod;
	}
	
	@:noCompletion private function set_wavePeriod(value:Float):Float 
	{	
		if (value != __wavePeriod) __renderDirty = true;
		__waveOmega = (Math.PI * 2) / value;
		return __wavePeriod = value;
	}
	
	@:noCompletion private function get_waveLenght():Int
	{
		return __waveLength;
	}
	
	@:noCompletion private function set_waveLenght(value:Int):Int 
	{	
		if (value != __waveLength) __renderDirty = true;
		return __waveLength = value;
	}
	
	@:noCompletion private function get_waveStep():Int
	{
		return __waveStep;
	}
	
	@:noCompletion private function set_waveStep(value:Int):Int 
	{	
		if (value != __waveStep) __renderDirty = true;
		return __waveStep = value;
	}
}

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

private class WaterShader extends BitmapFilterShader 
{	
	@:glFragmentSource("
		
		const float PI = 3.1415926535897932384626433832795;
	
		uniform sampler2D openfl_Texture;
		
		uniform vec2 openfl_TextureSize;
		
		uniform float uWaterLevel;
		uniform float uTime;
		uniform float uWaveAmp;
		uniform float uWaveOmega;
		uniform float uWaveLength;
		uniform float uWaveStep;
		
		varying vec2 openfl_TextureCoordV;
		
		void main(void) 
		{
		//	if (openfl_TextureCoordV.y > 1.0 - (uWaterHeight / openfl_TextureSize.y))
			if (openfl_TextureCoordV.y > (uWaterLevel / openfl_TextureSize.y))
			{
				float yMod = mod(openfl_TextureCoordV.y * openfl_TextureSize.y, uWaveLength);
				yMod = floor(yMod / uWaveStep) * uWaveStep;
				yMod = yMod / uWaveLength * (PI * 2.0);
				
				float xOffset = floor(sin(uTime * uWaveOmega + yMod) * uWaveAmp) / openfl_TextureSize.x;	
				vec2 offset = vec2(xOffset, 0.0);
				
				gl_FragColor = texture2D(openfl_Texture, openfl_TextureCoordV + offset);
			}
			else
			{
				gl_FragColor = texture2D(openfl_Texture, openfl_TextureCoordV);
			}
		}
	")
	
	@:glVertexSource("
		
		uniform mat4 openfl_Matrix;
		
		attribute vec4 openfl_Position;
		attribute vec2 openfl_TextureCoord;
		
		varying vec2 openfl_TextureCoordV;
		
		void main(void) {
			
			gl_Position = openfl_Matrix * openfl_Position;
			openfl_TextureCoordV = openfl_TextureCoord;
		}
	")
	
	public function new() 
	{
		super();
	}
}