import { NodeMaterialBlock } from "../nodeMaterialBlock";
import { NodeMaterialBlockConnectionPointTypes } from "../Enums/nodeMaterialBlockConnectionPointTypes";
import type { NodeMaterialBuildState } from "../nodeMaterialBuildState";
import { NodeMaterialBlockTargets } from "../Enums/nodeMaterialBlockTargets";
import type { NodeMaterialConnectionPoint } from "../nodeMaterialBlockConnectionPoint";
import { RegisterClass } from "../../../Misc/typeStore";
import type { Scene } from "../../../scene";
import type { InputBlock } from "./Input/inputBlock";
import type { AbstractMesh } from "../../../Meshes/abstractMesh";
import type { NodeMaterial, NodeMaterialDefines } from "../nodeMaterial";
import { ShaderLanguage } from "core/Materials/shaderLanguage";
import { editableInPropertyPage, PropertyTypeForEdition } from "core/Decorators/nodeDecorator";
export class TransformBlock extends NodeMaterialBlock {
    public complementW = 1;
    public complementZ = 0;
    @editableInPropertyPage("Transform as direction", PropertyTypeForEdition.Boolean, undefined, { embedded: true })
    public get transformAsDirection() {
        return this.complementW === 0;
    }
    public set transformAsDirection(value: boolean) {
        this.complementW = value ? 0 : 1;
    }
    public constructor(name: string) {
        super(name, NodeMaterialBlockTargets.Neutral);
        this.target = NodeMaterialBlockTargets.Vertex;
        this.registerInput("vector", NodeMaterialBlockConnectionPointTypes.AutoDetect);
        this.registerInput("transform", NodeMaterialBlockConnectionPointTypes.Matrix);
        this.registerOutput("output", NodeMaterialBlockConnectionPointTypes.Vector4);
        this.registerOutput("xyz", NodeMaterialBlockConnectionPointTypes.Vector3);
        this._inputs[0].onConnectionObservable.add((other) => {
            if (other.ownerBlock.isInput) {
                const otherAsInput = other.ownerBlock as InputBlock;
                if (otherAsInput.name === "normal" || otherAsInput.name === "tangent") {
                    this.complementW = 0;
                }
            }
        });
    }
    public override getClassName() {
        return "TransformBlock";
    }
    public get vector(): NodeMaterialConnectionPoint {
        return this._inputs[0];
    }
    public get output(): NodeMaterialConnectionPoint {
        return this._outputs[0];
    }
    public get xyz(): NodeMaterialConnectionPoint {
        return this._outputs[1];
    }
    public get transform(): NodeMaterialConnectionPoint {
        return this._inputs[1];
    }
    protected override _buildBlock(state: NodeMaterialBuildState) {
        super._buildBlock(state);
        const vector = this.vector;
        const transform = this.transform;
        const vec4 = state._getShaderType(NodeMaterialBlockConnectionPointTypes.Vector4);
        const vec3 = state._getShaderType(NodeMaterialBlockConnectionPointTypes.Vector3);
        if (vector.connectedPoint) {
            // None uniform scaling case.
            if (this.complementW === 0 || this.transformAsDirection) {
                const comments = `//${this.name}`;
                state._emitFunctionFromInclude("helperFunctions", comments);
                state.sharedData.blocksWithDefines.push(this);
                const transformName = state._getFreeVariableName(`${transform.associatedVariableName}_NUS`);
                if (state.shaderLanguage === ShaderLanguage.WGSL) {
                    state.compilationString += `var ${transformName}: mat3x3f = mat3x3f(${transform.associatedVariableName}[0].xyz, ${transform.associatedVariableName}[1].xyz, ${transform.associatedVariableName}[2].xyz);\n`;
                } else {
                    state.compilationString += `mat3 ${transformName} = mat3(${transform.associatedVariableName});\n`;
                }
                state.compilationString += `#ifdef NONUNIFORMSCALING\n`;
                state.compilationString += `${transformName} = transposeMat3(inverseMat3(${transformName}));\n`;
                state.compilationString += `#endif\n`;
                switch (vector.connectedPoint.type) {
                    case NodeMaterialBlockConnectionPointTypes.Vector2:
                        state.compilationString +=
                            state._declareOutput(this.output) +
                            ` = ${vec4}(${transformName} * ${vec3}(${vector.associatedVariableName}, ${this._writeFloat(this.complementZ)}), ${this._writeFloat(this.complementW)});\n`;
                        break;
                    case NodeMaterialBlockConnectionPointTypes.Vector3:
                    case NodeMaterialBlockConnectionPointTypes.Color3:
                        state.compilationString +=
                            state._declareOutput(this.output) + ` = ${vec4}(${transformName} * ${vector.associatedVariableName}, ${this._writeFloat(this.complementW)});\n`;
                        break;
                    default:
                        state.compilationString +=
                            state._declareOutput(this.output) + ` = ${vec4}(${transformName} * ${vector.associatedVariableName}.xyz, ${this._writeFloat(this.complementW)});\n`;
                        break;
                }
            } else {
                const transformName = transform.associatedVariableName;
                switch (vector.connectedPoint.type) {
                    case NodeMaterialBlockConnectionPointTypes.Vector2:
                        state.compilationString +=
                            state._declareOutput(this.output) +
                            ` = ${transformName} * ${vec4}(${vector.associatedVariableName}, ${this._writeFloat(this.complementZ)}, ${this._writeFloat(this.complementW)});\n`;
                        break;
                    case NodeMaterialBlockConnectionPointTypes.Vector3:
                    case NodeMaterialBlockConnectionPointTypes.Color3:
                        state.compilationString +=
                            state._declareOutput(this.output) + ` = ${transformName} * ${vec4}(${vector.associatedVariableName}, ${this._writeFloat(this.complementW)});\n`;
                        break;
                    default:
                        state.compilationString += state._declareOutput(this.output) + ` = ${transformName} * ${vector.associatedVariableName};\n`;
                        break;
                }
            }
            if (this.xyz.hasEndpoints) {
                state.compilationString += state._declareOutput(this.xyz) + ` = ${this.output.associatedVariableName}.xyz;\n`;
            }
        }
        return this;
    }
    public override prepareDefines(mesh: AbstractMesh, nodeMaterial: NodeMaterial, defines: NodeMaterialDefines) {
        // Do nothing
        if (mesh.nonUniformScaling) {
            defines.setValue("NONUNIFORMSCALING", true);
        }
    }
    public override serialize(): any {
        const serializationObject = super.serialize();
        serializationObject.complementZ = this.complementZ;
        serializationObject.complementW = this.complementW;
        return serializationObject;
    }
    public override _deserialize(serializationObject: any, scene: Scene, rootUrl: string) {
        super._deserialize(serializationObject, scene, rootUrl);
        this.complementZ = serializationObject.complementZ !== undefined ? serializationObject.complementZ : 0.0;
        this.complementW = serializationObject.complementW !== undefined ? serializationObject.complementW : 1.0;
    }
    protected override _dumpPropertiesCode() {
        let codeString = super._dumpPropertiesCode() + `${this._codeVariableName}.complementZ = ${this.complementZ};\n`;
        codeString += `${this._codeVariableName}.complementW = ${this.complementW};\n`;
        return codeString;
    }
}
RegisterClass("BABYLON.TransformBlock", TransformBlock);