class FigureSerializer < ActiveModel::Serializer
    attributes :id, :color, :type, :cell_name, :beaten_fields

    def cell_name
        object.cell.nil? ? nil : object.cell.name
    end
end
