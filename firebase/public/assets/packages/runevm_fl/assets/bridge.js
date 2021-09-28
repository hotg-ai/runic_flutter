
let input;
let output;


class ImageCapability {
    parameters = {};
    manifest;
    cap_id = 0;
    constructor(cap_id,manifest) {
        console.log("ImageCapability(",cap_id,",",manifest,")");
        this.manifest = manifest;
        this.cap_id = cap_id;
    }
    generate(dest,id) {
        dest.set(input, 0);
    }
    setParameter(key, value) {
        console.log("set parameter",key,value, this.cap_id);
        this.parameters[key] = value;
        if(this.manifest.length<=this.cap_id) {
            this.manifest[this.cap_id]={"type":"ImageCapability"};
        }
        this.manifest[this.cap_id][key] = value;
    }
 }

class SerialOutput {
    consume(data) {
        const utf8 = new TextDecoder();
        output=JSON.parse(utf8.decode(data));
    }
}

class Bridge {
    runtime;
    inputs;
    output;
    cap_count=0;
    manifest = [];
    constructor() {
        this.inputs = [{ "data": [] }];
        this.output = { "data": [] };
        console.log("bridge loaded");
    }
    
    async call(bytes) {
        
        input=bytes;
        await this.runtime.call();
        return JSON.stringify(output);
    }

    async load(bytes) {
        this.cap_count = 0;
        const imports = {
            createCapability: () => new ImageCapability(this.cap_count++,this.manifest),
            createOutput: () => new SerialOutput(),
            createModel: (mime, model_data) => rune.TensorFlowModel.loadTensorFlowLite(model_data),
            log: (log) => { console.log(log) },
        };
        var view = new Uint8Array(bytes);
        this.runtime=await rune.Runtime.load(view.buffer,imports);
        return JSON.stringify(this.manifest);
    }
}

bridge = new Bridge();