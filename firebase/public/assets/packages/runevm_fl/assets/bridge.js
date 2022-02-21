
let output;
let logs = [];
var manifestGlobal = {"manifest":[]};

const capabilitiesDefinition = {
    1: "RandCapability",
    2: "AudioCapability",
    3: "AccelCapability",
    4: "ImageCapability",
    5: "RawCapability"
  };

class RuneCapability {
    parameters = {};
    data;
    cap_id = 0;
    type=-1;
    constructor(cap_id,data,type) {
        this.cap_id = cap_id;
        this.data = data;
        this.type= type;
    }
    generate(dest,id) {
        dest.set(this.data.inputs[this.cap_id], 0);
    }
    setParameter(key, value) {
        this.parameters[key] = value;
        console.log("setParam",manifestGlobal["manifest"],key, value);
        if(manifestGlobal["manifest"].length<=this.cap_id) {
            
            manifestGlobal["manifest"][this.cap_id]={"type":capabilitiesDefinition[this.type]};
            
        }
        manifestGlobal["manifest"][this.cap_id][key] = value;
        console.log("updateing manifest ",manifestGlobal["manifest"]);
    }
 }

class SerialOutput {
    consume(data) {
        const utf8 = new TextDecoder();

        output=utf8.decode(data);
    }
}

class Bridge {
    runtime;
    data;
    cap_count=0;
    log = [];
    constructor() {
        this.data = [{ "inputs": [],  "outputs": [] }];
        console.log("bridge loaded");
    }
    
    async call(bytes,lengths) {
     
        logs=[]; 
        this.data.inputs=[];
        var pos=0;
        for(var i = 0;i<lengths.length;i++) {
            this.data.inputs[i]=bytes.subarray(pos, lengths[i]+pos);
            pos+=lengths[i];
        }

        await this.runtime.call();

        if(output.type_name=="f32") {
            return output.elements;
        }
        return output;
    }

    async load(bytes) {
        logs=[];
        this.cap_count = 0;
        console.log("Resetting manifest", manifestGlobal["manifest"]);
        manifestGlobal["manifest"] = [];
        console.log("Resetting manifest", manifestGlobal["manifest"]);
        const imports = {
            createCapability: (type) => new RuneCapability(this.cap_count++,this.data,type),
            createOutput: () => new SerialOutput(),
            createModel: (mime, model_data) => { 
                if(mime=="application/tfjs-model") {
                    return window.rune.loadTensorFlowJS(model_data);
                } else {
                    return window.rune.loadTensorFlowLite(model_data);
                    
                }
                
            },
            log: (log) => { logs.push(JSON.stringify(log)); },
        };
        console.log("Returning manifest",manifestGlobal["manifest"]);
        var view = new Uint8Array(bytes);
        await window.rune.tf.setBackend('wasm');
        this.runtime=await window.rune.Runtime.load(view.buffer,imports);
        console.log("Returning manifest",manifestGlobal["manifest"]);
        return JSON.stringify(manifestGlobal["manifest"]);
    }

    async getLogs() {
        return logs;
    }
}

bridge = new Bridge();