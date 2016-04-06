class FigureSerializer < ActiveModel::Serializer
    attributes :id, :color, :type, :cell_name

    def cell_name
        object.cell.name
    end
end
