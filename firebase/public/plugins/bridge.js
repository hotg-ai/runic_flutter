var AudioContext = window.AudioContext // Default
      || window.webkitAudioContext;

class AudioHelper {
    /*async decode(bytes) {
        let audioCtx =  new AudioContext();
        let view = new Uint8Array(bytes);
        console.log("decode");
        console.log(bytes);
        let audioBuffer = await audioCtx.decodeAudioData(view.buffer);

        return audioBuffer.getChannelData(0);
    }*/
    constructor() {
    }

    micstream;
    async initMic() {
        if(this.micstream === undefined) {
            this.micstream = await navigator.mediaDevices.getUserMedia({ audio: true, video: false });
        }
        
    }
    

    async decode(milliseconds) {
        const delay = ms => new Promise(res => setTimeout(res, ms));
       
       
       const mediaRecorder = new MediaRecorder(this.micstream);
       

       let audioChunks = new Uint8Array(0);

       mediaRecorder.addEventListener("dataavailable", async event =>  {
        console.log("event.data");
        console.log(event.data);
        let buffer = await new Response(event.data).arrayBuffer();
        audioChunks= new Uint8Array(buffer);
       });
       mediaRecorder.start();
       await delay(milliseconds);
       // we connect the recorder with the input stream
       mediaRecorder.stop();
       
       while(audioChunks.length==0) {
        await delay(50);
        console.log(audioChunks);
       }
       let audioCtx =  new AudioContext();
       let view = new Uint8Array(audioChunks);

       let audioBuffer = await audioCtx.decodeAudioData(view.buffer);

       return audioBuffer.getChannelData(0);
   }
}

var audio = new AudioHelper();