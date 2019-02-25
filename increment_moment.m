[value_matrix, count_matrix] = function increment_moment(value_matrix, count_matrix, draw, t, school_group, value)

value_matrix(draw, t, school_group) = value;
count_matrix(t, school_group) =  count_matrix(t, school_group) + 1;
