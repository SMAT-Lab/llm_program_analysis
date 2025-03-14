import { remoteQueryObjectToString } from "../remote-query-object-to-string"
const remoteQueryObject = {
  fields: [
    "id",
    "title",
    "subtitle",
    "status",
    "external_id",
    "description",
    "handle",
    "is_giftcard",
    "discountable",
    "thumbnail",
    "collection_id",
    "type_id",
    "weight",
    "length",
    "height",
    "width",
    "hs_code",
    "origin_country",
    "mid_code",
    "material",
    "created_at",
    "updated_at",
    "deleted_at",
    "metadata",
  ],
  images: {
    fields: ["id", "created_at", "updated_at", "deleted_at", "url", "metadata"],
  },
  tags: {
    fields: ["id", "created_at", "updated_at", "deleted_at", "value"],
  },
  type: {
    fields: ["id", "created_at", "updated_at", "deleted_at", "value"],
  },
  collection: {
    fields: ["title", "handle", "id", "created_at", "updated_at", "deleted_at"],
  },
  options: {
    fields: [
      "id",
      "created_at",
      "updated_at",
      "deleted_at",
      "title",
      "product_id",
      "metadata",
    ],
    values: {
      fields: [
        "id",
        "created_at",
        "updated_at",
        "deleted_at",
        "value",
        "option_id",
        "variant_id",
        "metadata",
      ],
    },
  },
  variants: {
    fields: [
      "id",
      "created_at",
      "updated_at",
      "deleted_at",
      "title",
      "product_id",
      "sku",
      "barcode",
      "ean",
      "upc",
      "variant_rank",
      "allow_backorder",
      "manage_inventory",
      "hs_code",
      "origin_country",
      "mid_code",
      "material",
      "weight",
      "length",
      "height",
      "width",
      "metadata",
    ],
    options: {
      fields: [
        "id",
        "created_at",
        "updated_at",
        "deleted_at",
        "value",
        "option_id",
        "variant_id",
        "metadata",
      ],
    },
  },
  profile: {
    fields: ["id", "created_at", "updated_at", "deleted_at", "name", "type"],
  },
}
describe("remoteQueryObjectToString", function () {
  it("should return a string array of fields/relations", function () {
    const output = remoteQueryObjectToString(remoteQueryObject)
    expect(output).toEqual([
      "id",
      "title",
      "subtitle",
      "status",
      "external_id",
      "description",
      "handle",
      "is_giftcard",
      "discountable",
      "thumbnail",
      "collection_id",
      "type_id",
      "weight",
      "length",
      "height",
      "width",
      "hs_code",
      "origin_country",
      "mid_code",
      "material",
      "created_at",
      "updated_at",
      "deleted_at",
      "metadata",
      "images.id",
      "images.created_at",
      "images.updated_at",
      "images.deleted_at",
      "images.url",
      "images.metadata",
      "tags.id",
      "tags.created_at",
      "tags.updated_at",
      "tags.deleted_at",
      "tags.value",
      "type.id",
      "type.created_at",
      "type.updated_at",
      "type.deleted_at",
      "type.value",
      "collection.title",
      "collection.handle",
      "collection.id",
      "collection.created_at",
      "collection.updated_at",
      "collection.deleted_at",
      "options.id",
      "options.created_at",
      "options.updated_at",
      "options.deleted_at",
      "options.title",
      "options.product_id",
      "options.metadata",
      "options.values.id",
      "options.values.created_at",
      "options.values.updated_at",
      "options.values.deleted_at",
      "options.values.value",
      "options.values.option_id",
      "options.values.variant_id",
      "options.values.metadata",
      "variants.id",
      "variants.created_at",
      "variants.updated_at",
      "variants.deleted_at",
      "variants.title",
      "variants.product_id",
      "variants.sku",
      "variants.barcode",
      "variants.ean",
      "variants.upc",
      "variants.variant_rank",
      "variants.allow_backorder",
      "variants.manage_inventory",
      "variants.hs_code",
      "variants.origin_country",
      "variants.mid_code",
      "variants.material",
      "variants.weight",
      "variants.length",
      "variants.height",
      "variants.width",
      "variants.metadata",
      "variants.options.id",
      "variants.options.created_at",
      "variants.options.updated_at",
      "variants.options.deleted_at",
      "variants.options.value",
      "variants.options.option_id",
      "variants.options.variant_id",
      "variants.options.metadata",
      "profile.id",
      "profile.created_at",
      "profile.updated_at",
      "profile.deleted_at",
      "profile.name",
      "profile.type",
    ])
  })
})