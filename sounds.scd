/*microtonal piano Synth!  the low keys are not quite there yet*/
SynthDef(\piano,
{ |freq=1.0, decayTime=0.5, amp=0.75, temp=100, out=10, done=2, pan=0, att=0.001, sus=0.1, rel=0.1, object=0.005, which=0|
	var sig, env, strike, envAttack, noise, delayTime, deTune;


		strike= Trig.ar(Impulse.ar((freq.asFloat.midicps)/temp),0.0001);
envAttack= Decay2.ar(strike, 0.008, 0.03);
noise= Mix(LFNoise2.ar([375,750,1500,3000], envAttack));

	sig= Mix(Array.fill(4,{|i|
		deTune= #[-0.05,0.01,0.04,-0.01].at(i);
	delayTime= 1/((freq.asFloat.midicps)+deTune);

	CombL.ar(
	noise, delayTime, delayTime, decayTime
			)

	}));
		sig= sig;
		sig= SelectX.ar(which,[sig, CombC.ar(sig, 1, object, 0.3, 1)]);

		env= EnvGen.kr(Env([0,1,1,0],[att,sus,rel]),doneAction: done);

		Out.ar(out, Limiter.ar(Pan2.ar(Mix(sig),pan)*amp,0.1)*env)
};
).add;




SynthDef(\reverb, {|in=10, out=0, gate=1|
	var sig, env;
	sig= FreeVerb2.ar(In.ar(in), In.ar(in+1), 0.2, 0.3, 0.2);
	env= EnvGen.kr(Env.asr(0.0001,1,0.1),gate, doneAction:2);
	Out.ar(out, sig*env)
}).add;