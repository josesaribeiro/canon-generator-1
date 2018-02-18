
s.boot;



(
// default netadress for the pbind to send messages;
~netAddr_0 = NetAddr("127.0.0.1", 57120);

);


(//another definition of ~x_values_V1


);

//~makeCanon.(~melodyMaker.simple4NoteMelody(2))[0]





//Example of a visualization
(
//--window setup
var width= 940, height= 480;
var w= Window("prueba", Rect(99, 99, width, height), false, scroll: true);
var u= UserView(w, Rect(0, 0, width, height));

	//--variables

var getXValues = {|durations|
	durations.inject((durs: List [], val: 0), {|acc, dur|
		acc.durs.add(acc.val);
		acc.val = dur+acc.val;
		acc;
	}).durs;
};

//~x_values_V1= ~getXValues.(~line);
var canon = ~makeCanon.((
            cp: 30,
            melody: [
		(dur: 0.21, note: 60), (dur: 0.35, note: 61), (dur: 0.45, note: 62), (dur: 0.17, note: 63), (dur: 0.24, note: 59),
		(dur: 0.21, note: 60), (dur: 0.35, note: 62), (dur: 0.45 - 0.20, note: 62), (dur: 0.17 - 0.01, note: 65), (dur: 0.24 - 0.02, note: 52),
		(dur: 0.21, note: 60), (dur: 0.35, note: 63), (dur: 0.45 - 0.22, note: 62), (dur: 0.17 - 0.02, note: 66), (dur: 0.24 - 0.03, note: 53),
		(dur: 0.21, note: 60), (dur: 0.35, note: 64), (dur: 0.45 - 0.24, note: 62), (dur: 0.17 - 0.03, note: 67), (dur: 0.24 - 0.02, note: 54),
		(dur: 0.21, note: 60), (dur: 0.35, note: 65), (dur: 0.45 - 0.26, note: 62), (dur: 0.17 - 0.04, note: 68), (dur: 0.24 - 0.01, note: 55),
		(dur: 0.21, note: 60), (dur: 0.35, note: 66), (dur: 0.45 - 0.28, note: 62), (dur: 0.17 - 0.05, note: 69), (dur: 0.24 - 0.02, note: 56),
		(dur: 0.21, note: 60), (dur: 0.35, note: 67), (dur: 0.45 - 0.31, note: 62), (dur: 0.17 - 0.06, note: 71), (dur: 4, note: 57)
	],
            voices: [
                (tempo: 90, transp: 0),
                (tempo: 95, transp: -12),
                (tempo: 100, transp: 12),
                (tempo: 83, transp: 8)
            ]
        ));
var y_values_V1 = canon[0].notes;
var line = canon[0].durs;
var x_values_V1 = getXValues.(line);
var xCoord =[0,0,0,0];
var yCoord = [0,0,0,0];
var colors = [Color.green(0.8), Color.red(0.8), Color.blue(0.8), Color.yellow(0.9)];
var durTotal = line.sum + 3;

var drawPoints = {
	|xVals, yVals, onset|

	xVals.size.do{|i|

		Pen.color = if( yVals[0]==(canon[0].notes[0]), {colors[0]}, {if(yVals[0]==canon[1].notes[0], {colors[1]}, if( yVals[0]==canon[2].notes[0], {colors[2]},{colors[3]}))});// set the Color


		// here the coordinates are expressed as an underlying map
		Pen.addWedge((xVals[i] + onset).linlin(0,(durTotal),10,940)@(yVals[i].linlin(20,120,0,480)), 4, 0pi, 2pi);
        Pen.perform(\fill);


	};

	(xVals.size-1).do{|i|
	Pen.line(
		Point((xVals[i] + onset).linlin(0,(durTotal),10,940),yVals[i].linlin(20,120,0,480)),
		Point((xVals[i+1] + onset).linlin(0,(durTotal),10,940),yVals[i+1].linlin(20,120,0,480))
	);
		Pen.strokeColor= if( yVals[0]==(canon[0].notes[0]), {colors[0]}, {if(yVals[0]==canon[1].notes[0], {colors[1]}, if( yVals[0]==canon[2].notes[0], {colors[2]},{colors[3]}))});


			Pen.stroke;
	}




};

var patterns = canon.collect({|line, index|
	Pbind(
		\instrument, \piano,
		\pan, 0,
		\dur, Pseq([line.onset.postln] ++ line.durs,1),
		\freq, Pseq([\rest]++line.notes,inf),
		\out, 0,
		\amp, 1,
		/*this series will provide an Index for later processes*/
		\series, Pseries(0,1,inf),
		/*messages to change the point positions in the map below*/
		\coordinates, Pfunc({|event|
				~netAddr_0.sendMsg(("/event"++index), event[\freq], event[\series], event[\dur])
		})
	)
});


w.drawFunc = { // draw the points of the canon;
canon.do({|line| drawPoints.(getXValues.(line.durs), line.notes, line.onset)});
};


//in U the present moment of the events will be emphasised visually in the map
u.drawFunc= {

	var selectMoment = {|index, line, onset|


		Pen.fillColor= Color(0.8,0.3,0.9);				//always fill with purple color

		// receive the data from the Pbind in realtime assigning global variables
		OSCdef("test"++index, {|msg, time, addr, recvPort| msg.postln;
			// if(msg[2] !== 1, {
				yCoord[index]=msg[1].linlin(20,120,0,480);
			xCoord[index]= (line[msg[2]] + onset).linlin(0,(durTotal),10,940);

		// })
		},
		("/event"++index), n);
		Pen.addWedge(Point(xCoord[index], yCoord[index]), 5, 0pi,2pi);
		Pen.fill;

	};

	u.frameRate= 60;
	canon.do({|line, i| selectMoment.(i, [0]++getXValues.(line.durs), line.onset)})
};


//--window management
u.clearOnRefresh= true;
w.background= Color.gray(0.05);
w.front;
u.animate= true;
CmdPeriod.doOnce({if(w.isClosed.not, {w.close; patterns.do(_.stop)})});

patterns.do(_.play)
)