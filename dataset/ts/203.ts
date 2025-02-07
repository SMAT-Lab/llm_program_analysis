import { Color, ColorRepresentation } from "../math/Color.js";
import { Texture } from "../textures/Texture.js";
import { Material, MaterialParameters } from "./Material.js";
export interface SpriteMaterialParameters extends MaterialParameters {
    color?: ColorRepresentation | undefined;
    map?: Texture | null | undefined;
    alphaMap?: Texture | null | undefined;
    rotation?: number | undefined;
    sizeAttenuation?: boolean | undefined;
    fog?: boolean | undefined;
}
export class SpriteMaterial extends Material {
    constructor(parameters?: SpriteMaterialParameters);
    readonly isSpriteMaterial: true;
    color: Color;
    map: Texture | null;
    alphaMap: Texture | null;
    rotation: number;
    sizeAttenuation: boolean;
    transparent: boolean;
    fog: boolean;
    setValues(parameters: SpriteMaterialParameters): void;
    copy(source: SpriteMaterial): this;
}